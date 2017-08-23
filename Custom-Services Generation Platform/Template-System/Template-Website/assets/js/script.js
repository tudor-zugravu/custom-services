function getTime(time) {
	if(time < 8) {
        return (time % 4 === 0) ? "0" + Math.floor(time / 4 + 8) + ":0" + ((time % 4) * 15) : "0" + Math.floor(time / 4 + 8) + ":" + ((time % 4) * 15);
    } else {
    	return (time % 4 === 0) ? Math.floor(time / 4 + 8) + ":0" + ((time % 4) * 15) : Math.floor(time / 4 + 8) + ":" + ((time % 4) * 15);
    }
}

function getTimeInt(time) {
	var timeComponents = time.split(":");
    return (parseInt(timeComponents[0]) - 8) * 4 + parseInt(timeComponents[1]) / 15;
}

function trimSeconds(time) {
    var timeComponents = time.split(":");
    return timeComponents[0] + ":" + timeComponents[1];
}

$(function() {
	var userId = 0;
	var credit = 0;
	var hasCategories = false;
	var systemType = "location";
	var categories = [];
	var allowedCategories = [];
    var offers = [];
    var receipts = [];
    var filteredOffers = [];
    var locationOffers = [];
    var maxDistance = 50;
    var minTime = "08:00";
    var maxTime = "24:00";
    var sortBy = 0;
    var onlyAvailableOffers = true;
    var allCategories = true;
    var distancesCalculated = 0;
    var viewingFavourites = false;
    var currentLocation;
    var startingTime, duration;
    var selectedCategory = 0;
    var selectedTimeInterval = 0;
    var appointments = [];
    var timeIntervals = [];
    var checkedStars = 2;
    var braintreeInstance;
    var creditAmount = 0;
    var viewingReceipts = false;

    function showReceipts() {	
		document.getElementById('receipts-display').innerHTML = "";
		for (var i = 0; i < receipts.length; i++) {
			var receiptCell = '<div class="row receipt-cell"><div class="col-6 receipt-details"><div class="row"><div class="col-2 no-padding"><img src="resources/vendor_images/' + receipts[i].logoImage + '" class="receipt-logo cell-button receipts-button-' + i + '"/></div><div class="col-10 no-padding"> <p class="receipt-title cell-button receipts-button-' + i + '"> ' + receipts[i].name + ' </p><p class="receipt-time-interval"> ' + receipts[i].timeInterval + ' </p></div></div></div><div class="col-2 cell-button receipts-button-' + i + '"></div><div class="col-2"><div class="row"><div class="col-12 no-padding"> <p class="receipt-title receipt-price"> ' + receipts[i].discount + ' GBP </p></div></div><div class="row min-top-margin"><div class="col-5"></div><div class="col-6 no-padding"><p class="rate-receipt ' + (receipts[i].redeemed == 1 ? ("receipt-rating-button receipt-rating-button-" + i) : "disabled-receipt-button") + '"> Rate Offer</p></div><div class="col-1 no-padding"><img src="resources/system_images/ratingFull.png" class="receipt-rating-logo ' + (receipts[i].redeemed == 1 ? ("receipt-rating-button receipt-rating-button-" + i) : "disabled-receipt-button") + '"/></div></div></div><div class="col-2 redeem-button-container"><div class="btn btn-default form-control ' + (receipts[i].redeemed == 0 ? "redeem-button-main-colour" : "disabled-colour") + ' disabled-details-button button redeem-button redeem-button-' + i + '"> ' + (receipts[i].redeemed == 0 ? "Receipt available" : (receipts[i].redeemed == 1 ? "Offer redeemed" : "Offer expired")) + '</div></div></div>';
			document.getElementById('receipts-display').innerHTML += receiptCell;
		}
	}

	function reloadTable() {
		filteredOffers = offers;
		filterOffers(viewingFavourites);
		sortOffers(0);
		filteredOffers = removeDuplicateLocations();
		sortOffers(sortBy);

		if ($('#menu-button-2').hasClass('active')) {
			initMap();
		} else {
			document.getElementById('display').innerHTML = "";
			for (var i = 0; i < filteredOffers.length; i++) {
				var offerCell = '<div class="row offer-cell"><div class="col-3 offer-details"><div class="row"><div class="col-4 no-padding"><img src="resources/vendor_images/' + filteredOffers[i].logoImage + '" class="offer-logo cell-button cell-button-' + i + '"/></div><div class="col-8 no-padding"> <p class="offer-title cell-button cell-button-' + i + '"> ' + filteredOffers[i].name + ' </p><p class="offer-time-interval"> ' + filteredOffers[i].startingTime + ' - ' + filteredOffers[i].endingTime + ' </p></div></div><div class="row offer-address-div"><div class="col-12 no-padding"><p class="offer-address"> ' + filteredOffers[i].address + ' </p></div></div><div class="row opaque-strip custom-opaque-colour"><div class="col-3 no-padding"><p class="offer-distance">' + (filteredOffers[i].distance > 1200 ? parseFloat(filteredOffers[i].distance / 1000).toFixed(1) + " km" : filteredOffers[i].distance + " m") + ' </p></div><div class="col-2 no-padding"><div class="row"><div class="col-7 no-padding"><p class="offer-rating">' + parseFloat(filteredOffers[i].rating).toFixed(1) + '</p></div><div class="col-5 no-padding"><img src="resources/system_images/ratingFull.png" class="rating-logo"/></div></div></div><div class="col-5 no-padding"><p class="offer-discount">' + ((filteredOffers[i].discountRange != null && filteredOffers[i].discountRange != "") ? filteredOffers[i].discountRange : filteredOffers[i].discount) + (systemType === "location" ? "% OFF" : " GBP") + '</p></div><div class="col-2 no-padding"><a href="" class="offer-favourite-button"><img src="resources/system_images/' + (filteredOffers[i].favourite ? 'fullHeart.png' : 'emptyHeart.png') + '" class="offer-favourite"/></a></div></div></div><div class="col-9 offer-image cell-button cell-button-' + i + '" style="background-image: url(/resources/vendor_images/' + filteredOffers[i].offerImage + '); background-size:100%;"></div></div>';
				document.getElementById('display').innerHTML += offerCell;
			};
		}
	}

	function getDistance(curLatitude, curLongitude, index) {
		if(window.google === undefined) {
	        console.log("Google Maps didn't load!");
	    } else {
	    	var service = new google.maps.DistanceMatrixService;
	    	service.getDistanceMatrix({
			origins: [{lat: curLatitude, lng: curLongitude}],
			destinations: [{lat: offers[index].latitude, lng: offers[index].longitude}],
			travelMode: 'WALKING',
			unitSystem: google.maps.UnitSystem.METRIC,
			avoidHighways: false,
			avoidTolls: false
	    }, function(response, status) {
			if (status !== 'OK') {
				console.log('Error was: ' + status);
				offers[index].distance = 0;
			} else {
				offers[index].distance = response.rows[0].elements[0].distance.value;
				distancesCalculated++;
				if (distancesCalculated == offers.length) {
					reloadTable();
				}
	    	}
	    });
	    }
	}

	function calculateDistances() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				var pos = {
					lat: position.coords.latitude,
					lng: position.coords.longitude
				};
				currentLocation = pos;
				for (var i = 0; i < offers.length; i++) {
		    		offers[i].distance = getDistance(pos.lat, pos.lng, i);
		    	}
			}, function() {
				alert('Error: The Geolocation service failed.');
			});
		} else {
			alert('Error: Your browser doesn\'t support geolocation.');
		}
	}

	function filterOffers(viewingFavourites) {
		filteredOffers = jQuery.grep(filteredOffers, function(offer, index) {
		  	if (viewingFavourites && !offer.favourite) {
                return false;
            }
		  	if (offer.distance > maxDistance * 1000) {
                return false;
            }
            if (offer.startingTime > maxTime || offer.endingTime <= minTime) {
                return false;
            }
            if (onlyAvailableOffers && offer.quantity === 0) {
                return false;
            }
            if (!allCategories && jQuery.grep(allowedCategories, function(category, index) {
            	if (category.name === offer.category) return true;
            }).length === 0) { 
                return false;
            }
            return true;
		});
    }

    function sortOffers(sortCriteria) {
    	filteredOffers = filteredOffers.sort(function(offer1, offer2) {
    		switch (parseInt(sortCriteria)) {
	            case 0: 
	                if (offer1.distance < offer2.distance) {
	                    return -1;
	                }
	                break;
	            case 1:
	                if (offer1.rating - offer2.rating > 0) {
	                    return -1;
	                }
	                if (Math.abs(offer1.rating - offer2.rating) < 0.000001 && offer1.distance < offer2.distance) {
	                    return -1;
	                }
	                break;
	            default:
	                var offer1Discount = 0;
	                var offer2Discount = 0;
	                if (systemType === "location") {
	                    if (offer1.discountRange != null && offer1.discountRange != "") {
	                        var discounts = offer1.discountRange.split("-");
	                        offer1Discount = parseFloat(discounts[1]);
	                    } else {
	                        offer1Discount = offer1.discount;
	                    }
	                    if (offer2.discountRange != null && offer2.discountRange != "") {
	                        var discounts = offer2.discountRange.split("-");
	                        offer2Discount = parseFloat(discounts[1]);
	                    } else {
	                        offer2Discount = offer2.discount;
	                    }
	                    if (offer1Discount - offer2Discount > 0) {
	                        return -1;
	                    }
	                    if (Math.abs(offer1Discount - offer2Discount) < 0.000001 && offer1.distance < offer2.distance) {
	                        return -1;
	                    }
	                } else {
	                    if (offer1.discountRange != null && offer1.discountRange != "") {
	                        var discounts = offer1.discountRange.split("-");
	                        offer1Discount = parseFloat(discounts[0]);
	                    } else {
	                        offer1Discount = offer1.discount;
	                    }
	                    if (offer2.discountRange != null && offer2.discountRange != "") {
	                        var discounts = offer2.discountRange.split("-");
	                        offer2Discount = parseFloat(discounts[0]);
	                    } else {
	                        offer2Discount = offer2.discount;
	                    }
	                    if (offer2Discount - offer1Discount > 0) {
	                        return -1;
	                    }
	                    if (Math.abs(offer1Discount - offer2Discount) < 0.000001 && offer2.distance < offer1.distance) {
	                        return -1;
	                    }
	                }
	            }
	        return 1;
    	});
    }

    function removeDuplicateLocations() {
    	var firstOffer;
    	if (filteredOffers.length > 0) {
    		firstOffer = filteredOffers[0];
    	} else {
    		return filteredOffers;
    	}
        
        var currentOffer = firstOffer;
        var numberOfFirsts = 0;
        
        if (onlyAvailableOffers && systemType != "location") {
            while (currentOffer.quantity == 0) {
                numberOfFirsts += 1;
                if (numberOfFirsts == filteredOffers.count) {
                    return [];
                } else {
                    currentOffer = filteredOffers[numberOfFirsts];
                }
            }
        }
        var uniqueOffers = [currentOffer]; // Keep first element
        
        for (var i = numberOfFirsts + 1; i < filteredOffers.length; i++) {
            if (systemType != "location" && (onlyAvailableOffers ? filteredOffers[i].quantity > 0 : true)) {
                if (filteredOffers[i].locationId == currentOffer.locationId && filteredOffers[i].id != currentOffer.id) {
                    if (filteredOffers[i].discount != currentOffer.discount) {
	                    if (currentOffer.discountRange != null && currentOffer.discountRange != "") {
	                        var discounts = currentOffer.discountRange.split(" - ");
	                        if (parseFloat(discounts[0]) - filteredOffers[i].discount > 0) {
	                            if (systemType == "location") {
	                                currentOffer.discountRange = parseInt(filteredOffers[i].discount) + " - " + discounts[1];
	                            } else {
	                                currentOffer.discountRange = filteredOffers[i].discount + " - " + discounts[1];
	                            }
	                        } else if (parseFloat(discounts[1]) - filteredOffers[i].discount < 0) {
	                            if (systemType == "location") {
	                                currentOffer.discountRange = discounts[0] + " - " + parseInt(filteredOffers[i].discount);
	                            } else {
	                                currentOffer.discountRange = discounts[0] + " - " + filteredOffers[i].discount;
	                            }
	                        }
	                    } else {
	                        if (systemType == "location") {
	                            currentOffer.discountRange = currentOffer.discount > filteredOffers[i].discount ? parseInt(filteredOffers[i].discount) + " - " + parseInt(currentOffer.discount) : parseInt(currentOffer.discount) + " - " + parseInt(filteredOffers[i].discount);
	                        } else {
	                            currentOffer.discountRange = currentOffer.discount > filteredOffers[i].discount ? filteredOffers[i].discount + " - " + currentOffer.discount : currentOffer.discount + " - " + filteredOffers[i].discount;
	                        }
	                    }
	                }
	                currentOffer.quantity += filteredOffers[i].quantity;
                } else {
                    currentOffer = filteredOffers[i];
                    uniqueOffers.push(currentOffer); // Found a different element
                }
            } else if (systemType == "location") {
                if (filteredOffers[i].locationId == currentOffer.locationId && filteredOffers[i].id != currentOffer.id) {
                	if (filteredOffers[i].discount != currentOffer.discount) {
	                    if (currentOffer.discountRange != null && currentOffer.discountRange != "") {
	                        var discounts = currentOffer.discountRange.split(" - ");
	                        if (parseFloat(discounts[0]) - filteredOffers[i].discount > 0) {
	                            if (systemType == "location") {
	                                currentOffer.discountRange = parseInt(filteredOffers[i].discount) + " - " + discounts[1];
	                            } else {
	                                currentOffer.discountRange = filteredOffers[i].discount + " - " + discounts[1];
	                            }
	                        } else if (parseFloat(discounts[1]) - filteredOffers[i].discount < 0) {
	                            if (systemType == "location") {
	                                currentOffer.discountRange = discounts[0] + " - " + parseInt(filteredOffers[i].discount);
	                            } else {
	                                currentOffer.discountRange = discounts[0] + " - " + filteredOffers[i].discount;
	                            }
	                        }
	                    } else {
	                        if (systemType == "location") {
	                            currentOffer.discountRange = currentOffer.discount > filteredOffers[i].discount ? parseInt(filteredOffers[i].discount) + " - " + parseInt(currentOffer.discount) : parseInt(currentOffer.discount) + " - " + parseInt(filteredOffers[i].discount);
	                        } else {
	                            currentOffer.discountRange = currentOffer.discount > filteredOffers[i].discount ? filteredOffers[i].discount + " - " + currentOffer.discount : currentOffer.discount + " - " + filteredOffers[i].discount;
	                        }
	                    }
	                }
	                currentOffer.quantity += filteredOffers[i].quantity;
                } else {
                    currentOffer = filteredOffers[i];
                    uniqueOffers.push(currentOffer); // Found a different element
                }
            }
        }
        return uniqueOffers;
    }

    if($("#all-categories-checkbox").length != 0) {
	  hasCategories = true;
	  $('.category-checkbox').each(function(index) {
	  	var categoryAux = {};
	  	categoryAux.id = index;
	  	categoryAux.name = $(this).val();
	  	categories.push(categoryAux);
	  });
	}
	systemType = $("#system-type").text();
	userId = parseInt($("#user-id").text());

	var SetSessionVariables = function(data, completionHandler) { 
		$.ajax({
	        url: "set_session_variables.php",
	        type: "POST",
	        dataType : "json",
	        data: data,
	        success : function (response) {
	        	completionHandler();
	        }
    	});  
	};

    $('#create-account-back').click(function(e) {
    	$("#register-form").fadeOut(100);
		$("#login-form").delay(150).fadeIn(100);
		e.preventDefault();
	});

	$('#create-account').click(function(e) {
		$("#login-form").fadeOut(100);
		$("#register-form").delay(150).fadeIn(100);
		e.preventDefault();
	});

	$('#login-form').submit(function(e) {
		e.preventDefault();
		var email = $('#login-form').find('input[name=email]').val();
		var password = $('#login-form').find('input[name=password]').val();
		if (email != "" && password != "") {
			$.ajax({
		        url: "services/login.php",
		        type: "POST",
		        dataType : "json",
		        data: { 
			        'email': email, 
			        'password': password
			    },
		        success : function (response) {
		        	if (response.status) {
		        		alert("Wrong email or password")
		        	} else {
		        		var completionHandler = function() {
					        window.location.replace("index.php");
					    }
					    credit = parseFloat(response.credit);
			            SetSessionVariables({ 
			            	'logged_in': true,
					        'user_id': response.user_id, 
					        'name': response.name,
					        'email': response.email,
					        'password': response.password,
					        'credit': response.credit,
					        'profile_picture': response.profile_picture
					    }, completionHandler);
			        }
		        }
	    	});
		} else {
			alert("Please fill both fields");
		}
    });

	$('#register-form').submit(function(e) {
		e.preventDefault();
		var name = $('#register-form').find('input[name=register-name]').val();
		var email = $('#register-form').find('input[name=register-email]').val();
		var password = $('#register-form').find('input[name=register-password]').val();
		var confirmPassword = $('#register-form').find('input[name=register-confirm-password]').val();
		if (name != "" && email != "" && password != "" && confirmPassword != "") {
			if (password === confirmPassword) {
				$.ajax({
			        url: "services/register.php",
			        type: "POST",
			        dataType : "json",
			        data: { 
			        	'name': name,
				        'email': email, 
				        'password': password
				    },
			        success : function (response) {
			        	if (response.insertId === 0) {
			        		alert("Email already linked to another account")
			        	} else {
			        		var completionHandler = function() {
						        window.location.replace("index.php");
						    }
				            SetSessionVariables({ 
				            	'logged_in': true,
						        'user_id': response.insertId, 
						        'name': name,
						        'email': email,
						        'password': password,
						        'credit': 0,
						        'profile_picture': ""
						    }, completionHandler);
				        }
			        }
		    	});
			} else {
				alert("The passwords do not match");
			}
		} else {
			alert("Please fill all fields");
		}
    });

	$('#log-out').click(function(e) {
		e.preventDefault();
		var completionHandler = function() {
	        window.location.replace("index.php");
	    }
		SetSessionVariables({ 'logged_in': false }, completionHandler);
	});

	$('#all-categories-checkbox').click(function() {
		if($('#all-categories-checkbox').is(':checked')) {
			$('#categories').hide();
		} else {
			$('#categories').show();
		}
	});

	$('.side-menu-button').click(function(e) {
		if ($(e.target).attr('id') != "menu-button-4") {
			$('.side-menu-button').removeClass("active");
			$(e.target).addClass("active");
		}
		switch($(e.target).attr('id')) {
			case "menu-button-1":
				$('#map-container').hide();
				$('#details-container').hide();
				$('#receipts-container').hide();
				$('#offers-container').show();
				viewingReceipts = false;
				viewingFavourites = false;
				requestOffers();
				$('#filtering-options').show();
				break;
			case "menu-button-2":
				$('#offers-container').hide();
				$('#details-container').hide();
				$('#receipts-container').hide();
				$('#map-container').show();
				viewingReceipts = false;
				viewingFavourites = false;
				requestOffers();
				initMap();
				$('#filtering-options').show();
				break;
			case "menu-button-3":
				$('#map-container').hide();
				$('#details-container').hide();
				$('#receipts-container').hide();
				$('#offers-container').show();
				viewingFavourites = true;
				viewingReceipts = false;
				requestOffers();
				$('#filtering-options').show();
				break;
			case "menu-button-4":
				if ($('#profile-container').hasClass('no-display')) {
					$('#profile-container').removeClass('no-display');
				} else {
					$('#profile-container').addClass('no-display');
				}
				break;
			default:
				$('#map-container').hide();
				$('#details-container').hide();
				$('#offers-container').hide();
				$('#receipts-container').show();
				viewingReceipts = true;
				requestReceipts();
				$('#filtering-options').hide();
		}
	});

	function addMarkerListener(map, marker, infoWindow, i) {
		marker.addListener('click', function() {
			var contentString = '<div class="row"><div class="col-12 offer-details"><div class="row"><div class="col-3 no-padding"><img src="resources/vendor_images/' + filteredOffers[i].logoImage + '" class="offer-logo-marker cell-button cell-button-' + i + '"/></div><div class="col-9 no-padding"> <p class="offer-title-marker cell-button cell-button-' + i + '"> ' + filteredOffers[i].name + ' </p><p class="offer-time-interval-marker"> ' + filteredOffers[i].startingTime + ' - ' + filteredOffers[i].endingTime + ' </p></div></div><div class="row"><div class="col-12"><p class="offer-address-marker"> ' + filteredOffers[i].address + ' </p></div></div><div class="row opaque-strip custom-opaque-colour"><div class="col-3 no-padding"><p class="offer-distance">' + (filteredOffers[i].distance > 1200 ? parseFloat(filteredOffers[i].distance / 1000).toFixed(1) + " km" : filteredOffers[i].distance + " m") + ' </p></div><div class="col-2 no-padding"><div class="row"><div class="col-7 no-padding"><p class="offer-rating">' + parseFloat(filteredOffers[i].rating).toFixed(1) + '</p></div><div class="col-5 no-padding"><img src="resources/system_images/ratingFull.png" class="rating-logo"/></div></div></div><div class="col-5 no-padding"><p class="offer-discount">' + ((filteredOffers[i].discountRange != null && filteredOffers[i].discountRange != "") ? filteredOffers[i].discountRange : filteredOffers[i].discount) + (systemType === "location" ? "% OFF" : " GBP") + '</p></div><div class="col-2 no-padding"><a href="" id="favourite-button-' + i + '" class="offer-favourite-button"><img src="resources/system_images/' + (filteredOffers[i].favourite ? 'fullHeart.png' : 'emptyHeart.png') + '" class="offer-favourite-marker"/></a></div></div></div></div><div class="row"><div class="col-12 offer-image-marker cell-button cell-button-' + i + '" style="background-image: url(/resources/vendor_images/' + filteredOffers[i].offerImage + '); background-size:100%;"></div></div>';
			infoWindow.setContent(contentString);
	        infoWindow.open(map, this);
		});
	}

	function initMap() {
		var map = new google.maps.Map(document.getElementById('the-map'), {
			zoom: 15,
			center: currentLocation
		});

		for (i = 0; i < filteredOffers.length; i++) {
			var marker = new google.maps.Marker({
				position: {
					lat: filteredOffers[i].latitude,
					lng: filteredOffers[i].longitude
				},
				map: map,
				title: filteredOffers[i].name
			});
			
			var infoWindow = new google.maps.InfoWindow();
			addMarkerListener(map, marker, infoWindow, i);
		}
	}

	$('#search-button').click(function(e) {
		e.preventDefault();

		if($('#all-categories-checkbox').prop('checked')) {
			allCategories = true;
			allowedCategories = categories;			
		} else {
			allCategories = false;
			var allowedCategoriesAux = [];
			$('#categories input:checked').each(function() {
				var value = $(this).val();
			    allowedCategoriesAux.push(jQuery.grep(categories, function(category, index) {
				  return category.name === value;
				})[0]);
			});
			if (allowedCategoriesAux.length === 0) {
				alert("Please select at least one category");
				return false;
			} else {
				allowedCategories = allowedCategoriesAux;
			}
		}

		maxDistance = parseInt($("#distance-label").text());
		var timeComponents = $('#time-interval-label').text().split(" - ");
		minTime = timeComponents[0];
		maxTime = timeComponents[1];
		sortBy = $('input[name=sortBy]:checked').val();
		onlyAvailableOffers = $('#only-available-offers').prop('checked');
		
		reloadTable();
	});

	function requestOffers() {
		$.ajax({
	        url: "services/offers.php",
	        type: "POST",
	        dataType : "json",
	        data: { 
	        	'userId': userId,
		        'hasCategories': hasCategories
		    },
	        success : function (response) {
	        	var offersAux = [];
	        	for (var i = 0; i < response.length; i++) {
	        		var offer = {};

	        		offer.id = response[i]['offer_id'];
	        		offer.locationId = response[i]['location_id'];
	        		offer.name = response[i]['name'];
	        		offer.address = response[i]['address'];
	        		offer.about = response[i]['about'];
	        		offer.discount = parseFloat(response[i]['discount']);
	        		offer.startingTime = trimSeconds(response[i]['starting_time']);
	        		offer.endingTime = trimSeconds(response[i]['ending_time']);
	        		offer.rating = parseFloat(response[i]['rating']);
	        		offer.latitude = parseFloat(response[i]['latitude']);
	        		offer.longitude = parseFloat(response[i]['longitude']);
	        		if (hasCategories) {
	        			offer.category = response[i]['category'];
	        		}
	        		offer.distance = 0;
					offer.quantity = response[i].hasOwnProperty('quantity') ? parseInt(response[i]['quantity']) : -1;
					offer.appointmentDuration = response[i].hasOwnProperty('appointment_minute_duration') ? parseInt(response[i]['appointment_minute_duration']) : -1;
					offer.favourite = response[i].hasOwnProperty('favourite') ? (response[i]['favourite'] === "1" ? true : false) : false;
					offer.logoImage = response[i]['logo_image'] === null ? "" : response[i]['logo_image'];
					offer.offerImage = response[i]['image'] === null ? "" : response[i]['image'];

	        		offersAux.push(offer);
	        	}

	        	offers = offersAux;
	        	distancesCalculated = 0;
	        	calculateDistances();
	        }
		});
	}

	function requestReceipts() {
		$.ajax({
	        url: "services/receipts.php",
	        type: "POST",
	        dataType : "json",
	        data: { 
	        	'userId': userId
		    },
	        success : function (response) {

	        	var currDate = new Date();
				var hour = currDate.getHours();
				if (parseInt(hour) < 10) { hour = "0" + hour; }
				var minute = currDate.getMinutes();
				if (parseInt(minute) < 10) { minute = "0" + minute; }
				var year = currDate.getFullYear();
				var month = parseInt(currDate.getMonth()) + 1;
				if (parseInt(month) < 10) { month = "0" + month; }
				var day = currDate.getDate();
				if (parseInt(day) < 10) { day = "0" + day; }
				var currentDate = year + "-" + month + "-" + day;
				var currentTime = hour + ":" + minute;

	        	var receiptsAux = [];
	        	for (var i = 0; i < response.length; i++) {
	        		var receipt = {};

	        		receipt.id = parseInt(response[i]['receipt_id']);
	        		receipt.locationId = response[i]['location_id'];
	        		receipt.offerId = response[i]['offer_id'];
	        		receipt.name = response[i]['name'];
	        		receipt.discount = parseFloat(response[i]['discount']);
	        		receipt.startingTime = trimSeconds(response[i]['starting_time']);
	        		receipt.endingTime = trimSeconds(response[i]['ending_time']);
	        		receipt.purchaseDate = response[i]['purchase_date'];
	        		receipt.redeemed = parseInt(response[i]['redeemed']);
	        		receipt.favourite = response[i].hasOwnProperty('favourite') ? (response[i]['favourite'] === "1" ? true : false) : false;
	        		receipt.logoImage = response[i]['logo_image'] === null ? "" : response[i]['logo_image'];

	        		var timeInterval = receipt.purchaseDate.split(" ")[0];
	        		if (systemType == "product") {
	        			receipt.timeInterval = timeInterval + " " + trimSeconds(receipt.startingTime) + " - " + trimSeconds(receipt.endingTime);
	        			if (currentDate <= timeInterval) {
	        				if (receipt.endingTime <= currentTime) {
	        					receipt.redeemed = receipt.redeemed == 1 ? 1 : 2;
	        				}
	        			} else {
	        				receipt.redeemed = receipt.redeemed == 1 ? 1 : 2
	        			}
	        		} else {
	        			var appointment = parseInt(response[i]["appointment_starting"]);
	        			var duration = parseInt(response[i]["appointment_minute_duration"]);
	        			receipt.timeInterval = timeInterval + " " + getTimeInterval(receipt.startingTime, duration, appointment);
	        			var timeComponents = receipt.timeInterval.split(" ");
	        			if (currentDate <= timeInterval) {
	        				if (timeComponents[1] < currentTime) {
	        					receipt.redeemed = receipt.redeemed == 1 ? 1 : 2;
	        				}
	        			} else {
	        				receipt.redeemed = receipt.redeemed == 1 ? 1 : 2
	        			}
	        		}
	        		receiptsAux.push(receipt);
	        	}

	        	receipts = receiptsAux.sort(function(receipt1, receipt2) {
	                if (receipt1.id > receipt2.id) {
	                    return -1;
	                };
	                return 1;
	            });
	            showReceipts();
	        }
		});
	}
                




	$('body').on('click', 'a.offer-favourite-button', function(e) {
		e.preventDefault();
		var index;
		if ($('#menu-button-2').hasClass('active')) {
			var elems = $('a.offer-favourite-button')[$('a.offer-favourite-button').length - 1].id.split('-');
			index = parseInt(elems[2]);
		} else {
			index = $('a.offer-favourite-button').index($(this));	
		}
		var element = $(this).children()[0];

        $.ajax({
	        url: "services/update_favourite.php",
	        type: "POST",
	        dataType : "json",
	        data: {
	        	'userId': userId,
	        	'locationId': filteredOffers[index].locationId,
	        	'favourite': !filteredOffers[index].favourite
	        },
	        success : function (response) {
	        	
	        	if (response === 1) {
		        	element.src = "resources/system_images/" + (filteredOffers[index].favourite ? "emptyHeart.png" : "fullHeart.png")
					filteredOffers[index].favourite = !filteredOffers[index].favourite;
					if (viewingFavourites && !filteredOffers[index].favourite) {
						$('.offer-cell')[index].style.display = "none";
					}
					$.map(offers, function(offer, i) {
						if (offer.locationId == filteredOffers[index].locationId) {
							offer.favourite = filteredOffers[index].favourite;
						}
					});
				}
	        }
    	});
	});

	if ($('#filtering-options').length === 1) {
		viewingFavourites = false;
		requestOffers();
	}

	$('body').on('click', '.cell-button', function(e) {
		var classList = $(this).attr('class').split(/\s+/);
		var elems = classList[classList.length - 1].split('-');
		var index = parseInt(elems[2]);
		
		$('#filtering-options').hide();
		$('#map-container').hide();
		$('#offers-container').hide();
		$('#receipts-container').hide();
		$('#details-container').show();


		locationOffers = jQuery.grep(offers, function(offer, i) {
		  	if (offer.locationId === (viewingReceipts ? receipts[index].locationId : filteredOffers[index].locationId)) {
                return true;
            }
            return false;
        });

        $('#details-title-value').text(locationOffers[0].name);
        $('#details-address-value').text(locationOffers[0].address);
        $('#details-time-interval-value').text(locationOffers[0].startingTime + " - " + locationOffers[0].endingTime);
        $('#details-about-value').text(locationOffers[0].about);
        $('#details-rating-value').text(parseFloat(locationOffers[0].rating).toFixed(1));
        $("#details-logo-image").attr("src","resources/vendor_images/" + locationOffers[0].logoImage);
        $("#details-main-image").attr("src","resources/vendor_images/" + locationOffers[0].offerImage);
        $('#details-favourite-image').attr("src","resources/system_images/" + (locationOffers[0].favourite ? "fullHeart.png" : "emptyHeart.png"));
        selectedCategory = 0;

        if(hasCategories) {
        	if (locationOffers.length == 1) {
        		$('#details-multiple-discount-section').hide();
        		$('#details-single-discount-section').show();
        		$('#details-single-discount-text').text(systemType == "location" ? (parseInt(locationOffers[0].discount) + "% discount for " + locationOffers[0].category) : (locationOffers[0].discount + " GBP for " + locationOffers[0].category));
        	} else {
        		$('weird-text').text(systemType == "location" ? "The discount for" : "The price for");
        		$('#details-single-discount-section').hide();
        		$('#details-multiple-discount-section').show();
        		$('#details-multiple-discount-text').text(systemType == "location" ? (parseInt(locationOffers[0].discount) + "%") : (locationOffers[0].discount + " GBP"));
        		$('#category-select').html("");
		        for (var i = 0; i < locationOffers.length; i++) {
		        	$('#category-select').html($('#category-select').html() + '<option class="details-text" value="' + i + '">' + locationOffers[i].category + '</option>');
		        }
		        $('#category-select').change(function() {
					selectedCategory = parseInt($("#category-select option:selected").val());
					var i = $("#category-select option:selected").val();
					$('#details-multiple-discount-text').text(systemType == "location" ? (parseInt(locationOffers[i].discount) + "%") : (locationOffers[i].discount + " GBP"));
					if (locationOffers[i].quantity == 0) {
						$('#purchase-offer').addClass('disabled-details-button');
			        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
					} else {
						$('#purchase-offer').removeClass('disabled-details-button');
			        	$('#purchase-offer').text("Purchase offer");
						if (systemType === "service") {
							requestAppointments(locationOffers[i].id, locationOffers[i].startingTime, locationOffers[i].endingTime, locationOffers[i].appointmentDuration);
							selectedTimeInterval = 0;
						}
					}
				});
        	}
        } else {
        	$('#details-multiple-discount-section').hide();
    		$('#details-single-discount-section').show();
    		$('#details-single-discount-text').text(systemType == "location" ? (parseInt(locationOffers[0].discount) + "% discount") : (locationOffers[0].discount + " GBP"));
        }
        if (systemType != "location") {
        	if (locationOffers[0].quantity === 0) {
	        	$('#purchase-offer').addClass('disabled-details-button');
	        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
	        } else {
	        	$('#purchase-offer').removeClass('disabled-details-button');
	        	$('#purchase-offer').text("Purchase offer");
	        }
		}
        if (systemType == "location") {
			$('#details-rating-section').show();
			$('#rate-location').show();
    		$('#purchase-offer').hide();
        } else {
        	$('#details-rating-section').hide();
			$('#rate-location').hide();
    		$('#purchase-offer').show();
        }
        if (systemType == "service") {
			requestAppointments(locationOffers[0].id, locationOffers[0].startingTime, locationOffers[0].endingTime, locationOffers[0].appointmentDuration);
			$('#details-time-interval-section').show();
    		startingTime = locationOffers[0].startingTime;
    		duration = locationOffers[0].appointmentDuration;
        } else {
        	$('#details-time-interval-section').hide();
        }
	});

	function requestAppointments(id, minTime, maxTime, appointmentDuration) {
		$.ajax({
	        url: "services/appointments.php",
	        type: "POST",
	        dataType : "json",
	        data: { 
		        'offerId': id
		    },
	        success : function (response) {
	        	appointments = response;
	        	timeIntervals = getTimeIntervals(minTime, maxTime, appointmentDuration);
	        	$('#time-interval-select').html("");
		        for (var i = 0; i < timeIntervals.length; i++) {
		        	$('#time-interval-select').html($('#time-interval-select').html() + '<option class="details-text" value="' + i + '">' + timeIntervals[i] + '</option>');
		        }
		        if (timeIntervals.length > 0) {
		        	checkTimeInterval(timeIntervals[0]);
		        }
		        $('#time-interval-select').change(function() {
					selectedTimeInterval = parseInt($("#time-interval-select option:selected").val());
					checkTimeInterval(timeIntervals[selectedTimeInterval]);
				});
	        }
    	});
	}

    function getTimeInterval(minTime, duration, appointment) {
    	var start = getMinutes(minTime);
    	return getHour(start + appointment * duration) + "-" + getHour(start + (appointment + 1) * duration);
    }

	function getTimeIntervals(minTime, maxTime, duration) {
		var start = getMinutes(minTime);
		var end = getMinutes(maxTime);
		var intervals = (end-start) / duration;
		var timeInt = [];

		for (var i = 0; i < intervals; i++) {
			if (jQuery.grep(appointments, function(appointment, index) {
				  return parseInt(appointment.appointment_starting) === i;
				}).length == 0) {
				timeInt.push(getHour(start + i * duration) + "-" + getHour(start + (i + 1) * duration));
			}
		}
		return timeInt;
	}

 	function getMinutes(time) {
 		var timeComponents = time.split(':');
 		return parseInt(timeComponents[0]) * 60 + parseInt(timeComponents[1]);
 	}

 	function getHour(time) {
 		if (time < 600) {
 			return time % 60 < 10 ? ("0" + Math.floor(time/60) + ":0" + time % 60) : ("0" + Math.floor(time/60) + ":" + time % 60);
 		} else {
 			return time % 60 < 10 ? (Math.floor(time/60) + ":0" + time % 60) : (Math.floor(time/60) + ":" + time % 60);
 		}
 	}

 	function getIndex(minTime, duration, time) {
 		var timeComponents = time.split('-');
 		return Math.floor((getMinutes(timeComponents[0]) - getMinutes(startingTime)) / duration);
 	}

 	function checkTimeInterval(time) {
 		var DateArray = time.split('-');
		var currDate = new Date();
		var hour = currDate.getHours();
		if (parseInt(hour) < 10) { hour = "0" + hour; }
		var minute = currDate.getMinutes();
		if (parseInt(minute) < 10) { minute = "0" + minute; }

		if (hour + ":" + minute > DateArray[0]) {
			$('#purchase-offer').addClass('disabled-details-button');
        	$('#purchase-offer').text("Expired time interval");
		} else {
			$('#purchase-offer').removeClass('disabled-details-button');
        	$('#purchase-offer').text("Purchase offer");
		}
 	}

	$('body').on('click', 'div.details-rating-star', function(e) {
		index = $('.details-rating-star').index($(this));	
		for (var i = 0; i < $('div.details-rating-star').length; i++) {
			if (i <= index) {
				$('div.details-rating-star')[i].classList.remove('empty-star');
				$('div.details-rating-star')[i].classList.add('full-star');
			} else {
				$('div.details-rating-star')[i].classList.remove('full-star');
				$('div.details-rating-star')[i].classList.add('empty-star');
			}
		};
		checkedStars = index + 1;
	});

	$('#rate-location').click(function(e) {
		e.preventDefault();
		if (confirm('Give ' + locationOffers[0].name + ' a ' + checkedStars + ' star rating?')) {
		    $.ajax({
		        url: "services/location_rating.php",
		        type: "POST",
		        dataType : "json",
		        data: { 
			        'userId': userId,
			        'locationId': locationOffers[0].locationId,
			        'rating': checkedStars
			    },
		        success : function (response) {
		        	if (response === true) {
		        		alert("Success! Thank you for your feedback");
		        	} else {
		        		alert("Error! Please try again");
		        	}
		        }
	    	});
		}
	});

	$('#get-directions').click(function(e) {
		e.preventDefault();
		window.open('https://www.google.com/maps/dir/?api=1&origin=' + currentLocation.lat + ',' + currentLocation.lng + '&destination=' + locationOffers[0].latitude + ',' + locationOffers[0].longitude,'_blank');
	});

	$('body').on('click', '.receipt-rating-button', function(e) {
		var classList = $(this).attr('class').split(/\s+/);
		var elems = classList[classList.length - 1].split('-');
		var index = parseInt(elems[3]);
		
		var ratingValue = prompt("How would you rate your experience on a scale from 1 to 5?");
		if (!isNaN(parseFloat(ratingValue))) {
			if (parseFloat(ratingValue) < 1 || parseFloat(ratingValue) > 5 || parseFloat(ratingValue) != Math.floor(parseFloat(ratingValue))) {
				alert("Please enter a number from 1 to 5!");
			} else {
				$.ajax({
			        url: "services/rating.php",
			        type: "POST",
			        dataType : "json",
			        data: { 
				        'receiptId': receipts[index].id,
				        'locationId': receipts[index].locationId,
				        'rating': parseInt(ratingValue)
				    },
			        success : function (response) {
			        	if (response.status == "success") {
			        		alert("Success! Thank you for your feedback");
			        	} else {
			        		alert("Error! Please try again");
			        	}
			        }
		    	});
			}
		} else {
			alert("Please enter a number from 1 to 5!");
		}

	});

	$('#profile-picture-button').click(function(e) {
		e.preventDefault();
		if (confirm("Upload a new profile picture?")) {
			$('#upload-form').removeClass('no-display');
		} else {
			$('#upload-form').addClass('no-display');
		}
	});

	$('#account-add-credit').click(function(e) {
		e.preventDefault();
		var amount = prompt("Enter the required amount.", "10.00");
		if (!isNaN(parseFloat(amount))) {
			// The Braintree component for authorising purchases has been created by following the steps provided at: https://developers.braintreepayments.com/guides/client-sdk/setup/javascript/v2
			braintree.dropin.create({
		      authorization: 'sandbox_44pm2mq7_9579dnmk65pnbf2z',
		      container: '#dropin-container'
		    }, function (createErr, instance) {
		    	creditAmount = amount;
		    	if (instance != null) {
			    	braintreeInstance = instance;
			    }
		      	$('#payment-submit').removeClass('no-display');
		      	$('#dropin-container').removeClass('no-display');
		    });
		} else {
			alert("Please enter a valid amount!");
		}
	});
	
	$('#payment-submit').click(function(e) {
		e.preventDefault();
		var instance = braintreeInstance;
		instance.requestPaymentMethod(function (requestPaymentMethodErr, payload) {
			$.ajax({
				url: "services/payment.php",
				type: "POST",
				dataType : "json",
				data: { 
					'userId': userId,
					'amount': creditAmount,
					'payment_method_nonce': payload.nonce
				},
				success : function (response) {
					if (response.success === true) {
						alert("Success! Your credit has been topped up");
						$('#account-password').val("");
						var completionHandler = function() {}
					    credit = parseFloat(response.amount);
					    $('#account-credit').val(credit + " GBP");
			            SetSessionVariables({ 'credit': credit }, completionHandler);
					} else {
						alert("There was a problem with your purchase!");
					}
				}
			});
			creditAmount = 0;
			$('#payment-submit').addClass('no-display');
			$('#dropin-container').addClass('no-display');
        });
	});

	$('#account-edit-button').click(function(e) {
		e.preventDefault();
		if ($('#account-name').prop('disabled')) {
			$(".account-details-input").prop('disabled', false);
		} else {
			var name = $('#account-name').attr("placeholder");
			var email = $('#account-email').attr("placeholder");
			if ($('#account-name').val() != null && $('#account-name').val() != "" && $('#account-email').val() != null && $('#account-email').val() != "") {
				if ($('#account-name').val() != name ||  $('#account-email').val() != email) {
					$.ajax({
				        url: "services/update_user_details.php",
				        type: "POST",
				        dataType : "json",
				        data: { 
					        'userId': userId,
					        'name': $('#account-name').val(),
					        'email': $('#account-email').val()
					    },
				        success : function (response) {
				        	if (response.status === true) {
				        		alert("Success! Your password has been changed");
				        		$('#account-name').attr("placeholder", $('#account-name').val());
								$('#account-email').attr("placeholder", $('#account-email').val());
				        		$(".account-details-input").prop('disabled', true);
				        	} else {
				        		alert("Incorrect password!");
				        	}
				        }
			    	});
				} else {
			    	$(".account-details-input").prop('disabled', true);
			    }
			} else {
				alert("Please fill in all the password fields!");
			}
		}
	});

	$('#account-change-password').click(function(e) {
		e.preventDefault();
		if ($('#account-password-container').hasClass('no-display')) {
			$('.password-form').removeClass('no-display');
		} else {
			if ($('#account-password').val() != null && $('#account-password').val() != "" && $('#account-new-password').val() != null && $('#account-new-password').val() != "" && $('#account-confirm-password').val() != null && $('#account-confirm-password').val() != "") {
				if ($('#account-new-password').val() == $('#account-confirm-password').val()) {
					$.ajax({
				        url: "services/change_password.php",
				        type: "POST",
				        dataType : "json",
				        data: { 
					        'userId': userId,
					        'oldPassword': $('#account-password').val(),
					        'newPassword': $('#account-new-password').val()
					    },
				        success : function (response) {
				        	if (response.status === true) {
				        		alert("Success! Your password has been changed");
				        		$('#account-password').val("");
				        		$('#account-new-password').val("");
				        		$('#account-confirm-password').val("");
				        		$('.password-form').addClass('no-display');
				        	} else {
				        		alert("Incorrect password!");
				        	}
				        }
			    	});
				} else {
					alert("Passwords do not match!");
				}
			} else {
				alert("Please fill in all the password fields!");
			}
		}
	});

	$('#purchase-offer').click(function(e) {
		e.preventDefault();
		
		if (systemType == "service") {
			if (confirm('Book an appointment for ' + locationOffers[selectedCategory].discount + ' GBP in between ' + timeIntervals[selectedTimeInterval] + '?')) {
			    $.ajax({
			        url: "services/service_checkout.php",
			        type: "POST",
			        dataType : "json",
			        data: { 
				        'userId': userId,
				        'offerId': locationOffers[selectedCategory].id,
				        'appointment': getIndex(locationOffers[selectedCategory].startingTime,  locationOffers[selectedCategory].appointmentDuration, timeIntervals[selectedTimeInterval])
				    },
			        success : function (response) {
			        	switch(response.status) {
							case "success":
								alert("Offer purchased! Voucher added to your receipts");
								credit = parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								timeIntervals.splice(selectedTimeInterval, 1);
								selectedTimeInterval = 0;
								locationOffers[selectedCategory].quantity -= 1;
								if (locationOffers[selectedCategory].quantity == 0) {
						        	$('#purchase-offer').addClass('disabled-details-button');
						        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
						        }
						        $('#time-interval-select').html("");
						        for (var i = 0; i < timeIntervals.length; i++) {
						        	$('#time-interval-select').html($('#time-interval-select').html() + '<option class="details-text" value="' + i + '">' + timeIntervals[i] + '</option>');
						        }
								break;
							case "offer_expired":
								alert("Unsuccessful! Offer has sold out");
								locationOffers[selectedCategory].quantity = 0;
								$('#time-interval-select').html("");
								selectedTimeInterval = 0;
								$('#purchase-offer').addClass('disabled-details-button');
					        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
								break;
							case "user_does_not_exist":
								window.location.replace("index.php");
								break;
							case "same_quantity":
								console.log("checkout error: " + response.status);
								credit -= parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								alert("An error has occured");
								break;
							case "no_receipt":
								console.log("checkout error: " + response.status);
								credit -= parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								locationOffers[selectedCategory].quantity -= 1;
								if (locationOffers[selectedCategory].quantity === 0) {
						        	$('#purchase-offer').addClass('disabled-details-button');
						        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
						        }
						        alert("An error has occured");
								break;
							case "insufficient_credit":
								alert("Insufficient credit! Please top up");
								break;
							default:
								console.log("checkout error: " + response.status);
								alert("An error has occured");
						}
			        }
		    	});
			}
		} else {
			if (confirm('Purchase this offer for ' + locationOffers[selectedCategory].discount + ' GBP?')) {
			    $.ajax({
			        url: "services/product_checkout.php",
			        type: "POST",
			        dataType : "json",
			        data: { 
				        'userId': userId,
				        'offerId': locationOffers[selectedCategory].id
				    },
			        success : function (response) {
			        	switch(response.status) {
							case "success":
								alert("Offer purchased! Voucher added to your receipts");
								credit -= parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								locationOffers[selectedCategory].quantity -= 1;
								if (locationOffers[selectedCategory].quantity === 0) {
						        	$('#purchase-offer').addClass('disabled-details-button');
						        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
						        }
								break;
							case "offer_expired":
								alert("Unsuccessful! Offer has sold out");
								locationOffers[selectedCategory].quantity = 0;
								$('#purchase-offer').addClass('disabled-details-button');
					        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
								break;
							case "user_does_not_exist":
								window.location.replace("index.php");
								break;
							case "same_quantity":
								console.log("checkout error: " + response.status);
								credit -= parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								alert("An error has occured");
								break;
							case "no_receipt":
								console.log("checkout error: " + response.status);
								credit -= parseFloat(response.credit);
								var completionHandler = function() {}
								SetSessionVariables({ 'credit': credit }, completionHandler);
								locationOffers[selectedCategory].quantity -= 1;
								if (locationOffers[selectedCategory].quantity === 0) {
						        	$('#purchase-offer').addClass('disabled-details-button');
						        	$('#purchase-offer').text(systemType == "product" ? "Sold out" : "Fully booked");
						        }
						        alert("An error has occured");
								break;
							case "insufficient_credit":
								alert("Insufficient credit! Please top up");
								break;
							default:
								console.log("checkout error: " + response.status);
								alert("An error has occured");
						}
			        }
		    	});
			}
		}
	});
	
});






