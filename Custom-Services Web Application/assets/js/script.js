$(function() {
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
});











