---
layout: default
title: All Events
---

<div class="max-w-4xl mx-auto px-4 py-8">
  <header class="mb-8">
    <h1 class="text-4xl font-bold text-red-600 mb-4">All Events</h1>
    <p class="text-lg text-gray-600">A complete list of all RubyZG meetups - past, present, and future.</p>
  </header>

  <!-- Upcoming Events -->
  {% assign upcoming_events = site.events | where_exp: "event", "event.date >= site.time" | sort: "date" %}
  {% if upcoming_events.size > 0 %}
    <section class="mb-12">
      <h2 class="text-2xl font-bold text-red-600 mb-6 flex items-center">
        <span class="mr-2">📅</span>
        Upcoming Events
      </h2>
      <div class="space-y-6">
        {% for event in upcoming_events %}
          <div class="bg-white rounded-lg shadow-md p-6 border-l-4 border-red-600">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between">
              <div class="flex-1">
                <h3 class="text-xl font-semibold mb-2">
                  <a href="{{ event.url | relative_url }}" class="text-gray-800 hover:text-red-600 transition">
                    {{ event.title }}
                  </a>
                </h3>
                <div class="flex items-center text-gray-600 mb-2">
                  <span class="mr-4">📅 {{ event.date | date: "%A, %B %d, %Y at %I:%M %p" }}</span>
                </div>
                {% if event.venue and event.venue != "TBD" and event.venue != "" %}
                  <p class="text-gray-600 mb-3">📍 {{ event.venue }}</p>
                {% endif %}
                <p class="text-gray-700 leading-relaxed">{{ event.content | strip_html | truncatewords: 40 }}</p>
              </div>
              <div class="mt-4 md:mt-0 md:ml-6 flex-shrink-0">
                <a href="{{ event.url | relative_url }}" class="inline-block bg-red-600 text-white font-medium py-2 px-4 rounded-lg hover:bg-red-700 transition">
                  View Event
                </a>
              </div>
            </div>
          </div>
        {% endfor %}
      </div>
    </section>
  {% endif %}

  <!-- Past Events -->
  {% assign past_events = site.events | where_exp: "event", "event.date < site.time" | sort: "date" | reverse %}
  {% if past_events.size > 0 %}
    <section>
      <h2 class="text-2xl font-bold text-red-600 mb-6 flex items-center">
        <span class="mr-2">📸</span>
        Past Events
      </h2>
      <div class="space-y-4">
        {% for event in past_events %}
          <div class="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
            <div class="flex flex-col md:flex-row md:items-start md:justify-between">
              <div class="flex-1">
                <h3 class="text-lg font-semibold mb-2">
                  <a href="{{ event.url | relative_url }}" class="text-gray-800 hover:text-red-600 transition">
                    {{ event.title }}
                  </a>
                </h3>
                <div class="flex flex-col sm:flex-row sm:items-center text-sm text-gray-600 mb-3">
                  <span class="mr-4">{{ event.date | date: "%B %d, %Y" }}</span>
                  {% if event.venue and event.venue != "TBD" and event.venue != "" %}
                    <span>📍 {{ event.venue }}</span>
                  {% endif %}
                </div>
                <p class="text-gray-700 text-sm leading-relaxed">{{ event.content | strip_html | truncatewords: 25 }}</p>
              </div>
              <div class="mt-3 md:mt-0 md:ml-6 flex-shrink-0">
                <a href="{{ event.url | relative_url }}" class="text-red-600 hover:text-red-800 font-medium text-sm">
                  Read more →
                </a>
              </div>
            </div>
          </div>
        {% endfor %}
      </div>
    </section>
  {% endif %}

  <!-- Empty state if no events -->
  {% unless upcoming_events.size > 0 or past_events.size > 0 %}
    <div class="text-center py-12">
      <div class="text-6xl mb-4">🗓️</div>
      <h2 class="text-2xl font-bold text-gray-800 mb-2">No Events Yet</h2>
      <p class="text-gray-600">Check back soon for upcoming RubyZG meetups!</p>
    </div>
  {% endunless %}

  <!-- Back to home -->
  <nav class="mt-12 pt-8 border-t border-gray-200">
    <a href="{{ '/' | relative_url }}" class="inline-flex items-center text-red-600 hover:text-red-800 font-medium">
      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
      </svg>
      Back to Home
    </a>
  </nav>
</div>