---
layout: landing
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
        <a href="https://www.meetup.com/rubyzg/" target="_blank" class="inline-block bg-white text-red-600 font-bold py-2 px-6 rounded-full shadow hover:bg-red-50 hover:scale-105 transition">🎉 Join the Meetup</a>
        <a href="https://www.meetup.com/rubyzg/events/?type=upcoming" target="_blank" class="inline-block bg-white text-red-600 font-bold py-2 px-6 rounded-full shadow hover:bg-red-50 hover:scale-105 transition">📅 Next Event</a>
      </div>
    </div>
  </div>
</header>

<section class="mt-12 px-2 sm:px-0">
  <h2 class="flex flex-row gap-3 text-3xl font-bold text-red-600 mb-4">
    <span><img src="{{ '/assets/images/logo/sideways_gem.svg' | relative_url }}" class="size-8"></span>
    <span>What’s RubyZG?</span>
  </h2>
  <p class="text-lg leading-relaxed px-2 sm:px-4">
    RubyZG is a casual, community-run meetup group for Ruby and Rails enthusiasts in Zagreb.
  </p>
  <p class="text-lg leading-relaxed px-2 sm:px-4">
    Whether you're a seasoned dev, a curious beginner, or just here to hang out and for the good vibes – you’re welcome here.
    We hang out, share ideas, hack on stuff, and learn together.
  </p>
</section>

<section class="mt-12 px-2 sm:px-0">
  <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-bold text-red-600 mb-2">Join Us</h3>
      <p class="text-lg text-gray-800 leading-relaxed mb-2">
        We meet regularly to chat, share knowledge, and enjoy each other's company. Drop by our next Meetup to see what it's all about!
      </p>
      <p class="text-lg text-gray-800 leading-relaxed mb-2">
        You don’t need to give a talk — just come hang out, grab a drink, and meet fellow Rubyists.
      </p>
      <p class="text-lg text-gray-800 leading-relaxed mb-4">
        Got something to share? Awesome —
        <a href="{{ '/give-a-talk/' | relative_url }}" class="text-red-600 hover:text-red-800 font-medium">
          sign up to speak
        </a>
      </p>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-bold text-red-600 mb-2">Host a Meetup</h3>
      <p class="text-lg text-gray-800 leading-relaxed mb-2">
        Want to host a RubyZG meetup at your space?
      </p>
      <p class="text-lg text-gray-800 leading-relaxed mb-2">
        We're always looking for friendly venues, and hosting is a great way to support the local dev community.
      </p>
      <p class="text-lg text-gray-800 leading-relaxed mb-4">
        If you've got a space and want to get involved, sign up to host here.
      </p>
      <a href="{{ '/host-a-meetup/' | relative_url }}" class="inline-block bg-red-600 text-white font-medium py-2 px-4 rounded-lg hover:bg-red-700 transition">
        Sign up to host →
      </a>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-bold text-red-600 mb-2">Our next Meetup</h3>
      {% assign upcoming_events = site.events | where_exp: "event", "event.date >= site.time" | sort: "date" %}
      {% if upcoming_events.size > 0 %}
        {% assign next_event = upcoming_events.first %}
        <div class="pt-4">
          <h4 class="font-semibold text-lg">{{ next_event.title }}</h4>
          <p class="text-gray-600 mb-2">{{ next_event.date | date: "%B %d, %Y at %I:%M %p" }}</p>
          {% if next_event.venue and next_event.venue != "TBD" %}
            <p class="text-gray-600 mb-2">📍 {{ next_event.venue }}</p>
          {% endif %}
          <p class="text-sm leading-relaxed">{{ next_event.content | strip_html | truncatewords: 30 }}</p>
          <div class="mt-3">
            <a href="{{ next_event.url | relative_url }}" class="inline-block text-red-600 hover:text-red-800 font-medium">Read more →</a>
          </div>
        </div>
      {% else %}
        <div class="pt-4">
          <p class="text-gray-600 text-center">🤷‍♂️ No events planned yet, but stay tuned!</p>
        </div>
      {% endif %}
    </div>

    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-bold text-red-600 mb-2">Past Meetups</h3>
      {% assign past_events = site.events | where_exp: "event", "event.date < site.time" | sort: "date" | reverse %}
      {% assign past_events = past_events | slice: 0, 1 %}
      {% if past_events.size > 0 %}
        {% assign latest_event = past_events.first %}
        <div class="pt-4">
          <h4 class="font-semibold text-lg">{{ latest_event.title }}</h4>
          <p class="text-gray-600 mb-2">{{ latest_event.date | date: "%B %d, %Y at %I:%M %p" }}</p>
          {% if latest_event.venue and latest_event.venue != "TBD" %}
            <p class="text-gray-600 mb-2">📍 {{ latest_event.venue }}</p>
          {% endif %}
          <p class="text-sm leading-relaxed">{{ latest_event.content | strip_html | truncatewords: 30 }}</p>
          <div class="mt-3">
            <a href="{{ latest_event.url | relative_url }}" class="inline-block text-red-600 hover:text-red-800 font-medium">Read more →</a>
          </div>
        </div>
        {% assign all_past_events = site.events | where_exp: "event", "event.date < site.time" %}
        {% if all_past_events.size > 1 %}
          <div class="mt-4 pt-4 border-t border-gray-200">
            <a href="/events/" class="text-sm text-red-600 hover:text-red-800 font-medium">Show all past Meetups →</a>
          </div>
        {% endif %}
      {% else %}
        <div class="pt-4">
          <p class="text-gray-600 text-center">📸 Our meetup history starts here!</p>
        </div>
      {% endif %}
    </div>
  </div>
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
