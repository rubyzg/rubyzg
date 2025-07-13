---
layout: default
---

<header class="carousel-container relative overflow-hidden h-96 rounded-b-2xl sm:rounded-b-[3rem]">
  <!-- Background carousel -->
  <div class="carousel absolute inset-0">
    {% assign image_files = site.static_files | where: "path", "/assets/images/meetups" %}
    {% for file in site.static_files %}
      {% if file.path contains "/assets/images/meetups/" %}
        <div class="carousel-slide absolute inset-0 opacity-0 transition-opacity duration-1000">
          <img data-src="{{ file.path | relative_url }}" alt="RubyZG Meetup" class="w-full h-full object-cover lazy-load">
        </div>
      {% endif %}
    {% endfor %}
  </div>

  <!-- Red semi-transparent overlay -->
  <div class="absolute inset-0 bg-red-600 bg-opacity-75"></div>

  <!-- Content overlay -->
  <div class="relative z-10 flex items-center justify-center h-full text-white text-center px-4">
    <div>
      <div class="relative mb-2">
        <h1 class="w-0 h-0 absolute top-0 left-0 overflow-hidden">RubyZG</h1>
        <img src="{{ '/assets/images/logo/hero.svg' | relative_url }}" alt="RubyZG Logo" class="max-w-[80%] sm:max-w-[50%] mx-auto mb-4">
      </div>
      <p class="text-xl mb-6">Zagreb's Ruby meetup group</p>
      <div class="flex flex-col sm:flex-row gap-4 mt-12 sm:mt-0 items-center justify-center">
        <a href="https://www.meetup.com/rubyzg/" target="_blank" class="inline-block bg-white text-red-600 font-bold py-2 px-6 rounded-full shadow hover:bg-red-50 transition">🎉 Join the Meetup</a>
        <a href="https://www.meetup.com/rubyzg/events/?type=upcoming" target="_blank" class="inline-block bg-white text-red-600 font-bold py-2 px-6 rounded-full shadow hover:bg-red-50 transition">📅 Next Event</a>
      </div>
    </div>
  </div>
</header>

<section class="mt-12 px-2 sm:px-0">
  <h2 class="text-3xl font-bold text-red-600 mb-4">
    👋 What’s RubyZG?
  </h2>
  <p class="text-lg leading-relaxed px-2 sm:px-4">
    RubyZG is a casual, community-run meetup group for Ruby and Rails enthusiasts in Zagreb.
  </p>
  <p class="text-lg leading-relaxed px-2 sm:px-4">
    Whether you're a seasoned dev, a curious beginner, or just here to hang out and for the good vibes – you’re welcome here.
    We hang out, share ideas, hack on stuff, and learn together.
  </p>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const slides = document.querySelectorAll('.carousel-slide');
  const lazyImages = document.querySelectorAll('.lazy-load');
  let currentSlide = 0;
  let loadedImages = new Set();

  if (slides.length === 0) return;

  function loadImage(img) {
    if (img.dataset.src && !loadedImages.has(img)) {
      img.src = img.dataset.src;
      loadedImages.add(img);
    }
  }

  const firstImg = slides[0].querySelector('.lazy-load');
  if (firstImg) loadImage(firstImg);

  slides[0].classList.remove('opacity-0');
  slides[0].classList.add('opacity-100');

  function nextSlide() {
    slides[currentSlide].classList.remove('opacity-100');
    slides[currentSlide].classList.add('opacity-0');

    currentSlide = (currentSlide + 1) % slides.length;

    const currentImg = slides[currentSlide].querySelector('.lazy-load');
    if (currentImg) loadImage(currentImg);

    const nextIndex = (currentSlide + 1) % slides.length;
    const nextImg = slides[nextIndex].querySelector('.lazy-load');
    if (nextImg) loadImage(nextImg);

    slides[currentSlide].classList.remove('opacity-0');
    slides[currentSlide].classList.add('opacity-100');
  }

  setInterval(nextSlide, 4000);
});
</script>
