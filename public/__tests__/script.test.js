const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.resolve('./index.html'));
const { window } = new JSDOM(html);
const { document } = window;

const scriptPath = path.resolve('./script.js');
require(scriptPath);

test('Form submission event handler', () => {
  const form = document.querySelector('form');

  const inputCompany = document.querySelector('#company');
  inputCompany.value = '';

  const inputFirstName = document.querySelector('#first_name');
  inputFirstName.value = '';

  const inputLastName = document.querySelector('#last_name');
  inputLastName.value = '';

  const inputEmail = document.querySelector('#email');
  inputEmail.value = '';

  const preventDefault = jest.fn();
  form.dispatchEvent(new Event('submit', { cancelable: true }));

  expect(preventDefault).toHaveBeenCalled();
  expect(window.alert).toHaveBeenCalledWith('Please fill in Company');
  expect(window.alert).toHaveBeenCalledWith('Please fill in First Name');
  expect(window.alert).toHaveBeenCalledWith('Please fill in Last Name');
  expect(window.alert).toHaveBeenCalledWith('Please fill in Email');
});
