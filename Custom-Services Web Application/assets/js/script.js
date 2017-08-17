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
	var hasCategories = false;
	var systemType = "location";
	var categories = [];
	var allowedCategories = [];
    var offers = [];
    var filteredOffers = [];
    var maxDistance = 50;
    var minTime = "08:00";
    var maxTime = "24:00";
    var sortBy = 0;
    var onlyAvailableOffers = true;
    var allCategories = true;
    var distancesCalculated = 0;

	function reloadTable() {
		filteredOffers = offers;
		filterOffers();
		sortOffers(0);
		filteredOffers = removeDuplicateLocations();
		sortOffers(sortBy);

		document.getElementById('display').innerHTML = "";
		for (var i = 0; i < filteredOffers.length; i++) {
			var offerCell = '<div class="row offer-cell"><div class="col-3 offer-details"><div class="row"><div class="col-4 no-padding"><img src="resources/vendor_images/' + filteredOffers[i].logoImage + '" class="offer-logo"/></div><div class="col-8 no-padding"> <p class="offer-title"> ' + filteredOffers[i].name + ' </p><p class="offer-time-interval"> ' + filteredOffers[i].startingTime + ' - ' + filteredOffers[i].endingTime + ' </p></div></div><div class="row"><div class="col-12 no-padding"><p class="offer-address"> ' + filteredOffers[i].address + ' </p></div></div><div class="row opaque-strip custom-opaque-colour"><div class="col-3 no-padding"><p class="offer-distance">' + (filteredOffers[i].distance > 1200 ? parseFloat(filteredOffers[i].distance / 1000).toFixed(1) + " km" : filteredOffers[i].distance + " m") + ' </p></div><div class="col-2 no-padding"><div class="row"><div class="col-7 no-padding"><p class="offer-rating">' + parseFloat(filteredOffers[i].rating).toFixed(1) + '</p></div><div class="col-5 no-padding"><img src="resources/system_images/ratingFull.png" class="rating-logo"/></div></div></div><div class="col-5 no-padding"><p class="offer-discount">' + ((filteredOffers[i].discountRange != null && filteredOffers[i].discountRange != "") ? filteredOffers[i].discountRange : filteredOffers[i].discount) + (systemType === "location" ? "% OFF" : " GBP") + '</p></div><div class="col-2 no-padding"><a href="" class="offer-favourite-button"><img src="resources/system_images/' + (filteredOffers[i].favourite ? 'fullHeart.png' : 'emptyHeart.png') + '" class="offer-favourite"/></a></div></div></div><div class="col-9 offer-image" style="background-image: url(/resources/vendor_images/' + filteredOffers[i].offerImage + '); background-size:100%;"></div></div>';
			document.getElementById('display').innerHTML += offerCell;
		};
	}

	function getDistance(curLatitude, curLongitude, index) {
		if(window.google === undefined) {
	        alert("Google Maps didn't load!");
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

	function filterOffers() {
		filteredOffers = jQuery.grep(filteredOffers, function(offer, index) {
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
                if (filteredOffers[i].locationId == currentOffer.locationId && filteredOffers[i].id != currentOffer.id && filteredOffers[i].discount != currentOffer.discount) {
                    currentOffer.quantity += filteredOffers[i].quantity;
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
                } else {
                    currentOffer = filteredOffers[i];
                    uniqueOffers.push(currentOffer); // Found a different element
                }
            } else if (systemType == "location") {
                if (filteredOffers[i].locationId == currentOffer.locationId && filteredOffers[i].id != currentOffer.id && filteredOffers[i].discount != currentOffer.discount) {
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
	        	console.log(response);
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
		$('.side-menu-button').removeClass("active");
		$(e.target).addClass("active");
		switch($(e.target).attr('id')) {
			case "menu-button-1":
				requestOffers();
				break;
			case "menu-button-2":
				console.log("2");
				break;
			case "menu-button-3":
				console.log("3");
				break;
			case "menu-button-4":
				console.log("4");
				break;
			default:
				console.log("5");
		}
	});

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

	$('.offer-favourite-button').on('click', 'a', function (e) {
        alert('this is the click');
        e.preventDefault();
    });

	if ($('.filtering-options').length === 1) {
		requestOffers();
	}
});







		// console.log("Has categories: " + hasCategories);
		// console.log("Max distance: " + maxDistance);
		// console.log("Min time: " + minTime);
		// console.log("Max time: " + maxTime);
		// console.log("Sort by: " + sortBy);
		// console.log("All offers: " + onlyAvailableOffers);
		// console.log("All categories: " + allCategories);
		// console.log("Allowed categories: " + allowedCategories);







