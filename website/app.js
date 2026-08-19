function scrollToSection(id) {
    document.getElementById(id).scrollIntoView({ behavior: "smooth" });
}

document.querySelector(".contact-form").addEventListener("submit", (e) => {
    e.preventDefault();
    alert("Message sent! We’ll get back to you soon.");
});
