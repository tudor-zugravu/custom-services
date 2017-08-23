$(function() {
	var title, tabTitle, colour1, colour2, colour3, colour4;
	var selectedType = 0;
	var notifications = 0;
	var categories = 0;
    var braintreeInstance;

	$('#generate-button').click(function(e) {
		e.preventDefault();

		if ($('#title').val() == null || $('#title').val() == "" || $('#tab-title').val() == null || $('#tab-title').val() == "" || $('#colour1').val() == null || $('#colour1').val() == "" || $('#colour2').val() == null || $('#colour2').val() == "" || $('#colour3').val() == null || $('#colour3').val() == "" || $('#colour4').val() == null || $('#colour4').val() == "") {
			alert("Please fill in all the required fields");
		} else {
			if (confirm("Order this system for the amount of 1.000.000 GBP?")) {
				title = $('#title').val();
				tabTitle = $('#tab-title').val();
				colour1 = $('#colour1').val();
				colour2 = $('#colour2').val();
				colour3 = $('#colour3').val();
				colour4 = $('#colour4').val();

				braintree.dropin.create({
			      authorization: 'sandbox_44pm2mq7_9579dnmk65pnbf2z',
			      container: '#dropin-container'
			    }, function (createErr, instance) {
			    	if (instance != null) {
				    	braintreeInstance = instance;
				    }
			      	$('#payment-submit').removeClass('no-display');
			      	$('#dropin-container').removeClass('no-display');
			      	$('#generate-button').addClass('no-display');
			    });
			}
		}
	});
	
	$('#payment-submit').click(function(e) {
		e.preventDefault();
		var instance = braintreeInstance;
		instance.requestPaymentMethod(function (requestPaymentMethodErr, payload) {
			generateSystem();
			alert("Payment has been successful\nPlease wait, system is configuring");
			$('#payment-submit').addClass('no-display');
			$('#dropin-container').addClass('no-display');
			$('#generate-button').removeClass('no-display');
        });
	});

	function generateSystem() {
		$.ajax({
	        url: "generate.php",
	        type: "POST",
	        dataType : "json",
	        data: { 
	        	'title': title,
		        'tabTitle': tabTitle,
		        'colour1': colour1,
		        'colour2': colour2,
		        'colour3': colour3,
		        'colour4': colour4,
		        'selectedType': selectedType,
		        'notifications': notifications,
		        'categories': categories
		    },
	        success : function (response) {
	        	if (response) {
	        		alert("Please download your solution from https://custom-services.co.uk/generate/solution.zip");
	        	} else {
	        		alert("There has been a problem");
	        	}
	        }
		});
	}

	$('#system-type-select').change(function() {
		selectedType = parseInt($("#system-type-select option:selected").val());
	});

	$('#system-categories-select').change(function() {
		categories = parseInt($("#system-categories-select option:selected").val());
	});

	$('#system-geolocations-select').change(function() {
		notifications = parseInt($("#system-geolocations-select option:selected").val());
	});
});