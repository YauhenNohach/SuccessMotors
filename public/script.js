
window.onload = function() {
  document.querySelector('form').onsubmit = function(event) {
    var captchaResponse = document.getElementById("g-recaptcha-response").value;
    if (captchaResponse.trim() === '') {
      event.preventDefault();
      alert('Please complete the CAPTCHA');
      return;
    }

    var inputs = document.querySelectorAll('input[type=text], input[type=email], input[type=tel], select');
    var isValid = true;

    inputs.forEach(function(input) {
      if (input.name === "first_name" || input.name === "last_name" || input.name === "company") {
        var regex = /^[a-zA-Z]+$/;
        if (!regex.test(input.value.trim())) {
          isValid = false;
          alert('Please enter only letters for ' + input.name);
        }
      } else if (input.name === "email") {
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          if (!emailRegex.test(input.value.trim())) {
            isValid = false;
            alert('Please enter a valid email address');
          } else if (!input.value.trim().endsWith('.com')) {
            isValid = false;
            alert('Email address must end with .com');
          }
      } else {
        if (input.value.trim() === '') {
          isValid = false;
          alert('Please fill in ' + input.name);
        }
      }
    });

    if (!isValid) {
      event.preventDefault();
    } else {
      alert('The order has been sent');
    }
  };
};
