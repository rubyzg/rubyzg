# RubyZG Website

The official website for RubyZG

## About

RubyZG is a casual, community-run meetup group for Ruby and Rails enthusiasts in Zagreb. We regularly organize meetups featuring technical talks, networking opportunities, and socializing within the local Ruby community.

This website serves as our central hub for event information, community resources, and announcements.

## Tech Stack

- **Jekyll** - Static site generator
- **Tailwind CSS** - Utility-first CSS framework
- **Ruby** - For automation scripts

## Development Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Run the development server:**
   ```bash
   bundle exec jekyll serve --livereload
   ```

3. **Visit the site:**
   ```
   http://localhost:4000
   ```

## Content Management

### Adding New Images

When you add new meetup photos:

1. **Add raw images** to the appropriate event folder in `assets/images/meetups/YYYY-MM-DD-event-name/`

2. **Run the optimization script** before committing:
   ```bash
   ruby scripts/optimize_meetup_images.rb
   ```

   This script will:
   - Resize images to maximum 1200×800px
   - Convert all images to optimized JPG format
   - Rename them with uniform naming (`photo_001.jpg`, `photo_002.jpg`, etc.)
   - Remove original files after optimization
   - Skip already optimized images (idempotent)

3. **Commit the optimized images** to the repository

### Event Management

#### Fetching New Events

The `fetch_meetup_events.rb` script automatically pulls new events from Meetup.com:

```bash
ruby scripts/fetch_meetup_events.rb
```

This script should be run periodically (manually or via automation) to keep the website synchronized with new events posted on Meetup.com. It:
- Fetches upcoming and recent events via GraphQL API
- Creates markdown files in the `_events/` directory
- Sets up proper frontmatter for Jekyll processing
- Handles venue information and event descriptions

#### Importing Historical Events

For initial setup or bulk import of past events, use:

```bash
ruby scripts/import_past_events.rb
```

This script was used to initially populate the site with historical meetup data and is typically only run once during setup.

## Project Structure

```
├── _events/           # Event markdown files
├── _includes/         # Jekyll includes (header, footer)
├── _layouts/          # Jekyll layouts (default, event, landing)
├── assets/
│   ├── css/          # Stylesheets
│   └── images/       # Images and meetup photos
├── scripts/          # Ruby automation scripts
├── events.xml        # RSS feed for events
└── *.md             # Main site pages
```

## Deployment

The site is deployed automatically via GitHub Pages when changes are pushed to the main branch.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run image optimization if you added photos
5. Test locally with `bundle exec jekyll serve`
6. Submit a pull request

## Scripts Reference

- **`optimize_meetup_images.rb`** - Optimizes and standardizes meetup photos
- **`fetch_meetup_events.rb`** - Syncs events from Meetup.com API
- **`import_past_events.rb`** - Bulk import historical events (one-time use)

## License

This project is open source. See the LICENSE file for details.
