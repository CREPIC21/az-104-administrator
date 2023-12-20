

let openModalBtn = document.querySelector(".open-modal");
let modal = document.querySelector(".modal");
let closeModalBtn = document.querySelector(".btn-close-modal");
let hamburgerMenuOpenBtn = document.querySelector(".hamb-menu");
let hamburgerNavbar = document.querySelector(".hamburger-style");
let hamburgerMenuCloseBtn = document.querySelector(".close-hamburger-navbar-btn");

async function increaseCount() {
  let count = await getVisitorCount();

  // Convert count to a number if it's a string
  count = parseInt(count); // or parseFloat(count) for decimal values

  if (!isNaN(count)) {
    console.log('Parsed count:', count);

    // Increment count as a number
    count++;

    // Convert back to string before sending to the database
    const countAsString = count.toString();

    fetch('https://countresumefunc.azurewebsites.net/api/HttpTrigger1?code=w4EbTz88WNMUasC90nPVJ2PEcen-te1nH48qesx0ZqhbAzFu5P0dBw==', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ count: countAsString })
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Failed to update visitor count');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        // Handle error here
      });
  } else {
    console.error('Invalid count:', count);
  }
}

// Function to retrieve visitor count from Azure Function
async function getVisitorCount() {
  try {
    const response = await fetch('https://countresumefunc.azurewebsites.net/api/HttpTrigger1?code=w4EbTz88WNMUasC90nPVJ2PEcen-te1nH48qesx0ZqhbAzFu5P0dBw==', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (response.ok) {
      const data = await response.json();
      document.getElementById('counter').innerText = data.count;
      return data.count;
    } else {
      throw new Error('Failed to fetch visitor count');
    }
  } catch (error) {
    console.error('Error:', error);
    return 0; // Return default value on error
  }
}

// Call increaseCount every 5 seconds
setInterval(getVisitorCount, 5000);

window.onload = function () {
  increaseCount();
};


openModalBtn.addEventListener("click", function () {
  modal.classList.add("modal-open");
});

closeModalBtn.addEventListener("click", function () {
  modal.classList.remove("modal-open");
});

hamburgerMenuOpenBtn.addEventListener("click", function () {
  console.log("Clicked");
  hamburgerNavbar.classList.add("hamburger-style-open");
  hamburgerMenuOpenBtn.classList.add("hamb-menu-hide");

})

hamburgerMenuCloseBtn.addEventListener("click", function () {
  hamburgerNavbar.classList.remove("hamburger-style-open");
  hamburgerMenuOpenBtn.classList.remove("hamb-menu-hide");
})
