# CocktailsApp API

A mock REST API server for the CocktailsApp iOS application, built with [json-server](https://github.com/typicode/json-server).

## Overview

This API provides endpoints for managing users, cocktails, bookmarks, and reviews for the CocktailsApp. It uses a JSON file as a database for quick development and testing.

## Prerequisites

- Node.js (v16 or higher)
- pnpm (v8 or higher)

## Installation

```bash
pnpm install
```

## Running the Server

Start the API server on port 3000:

```bash
pnpm run api
```

The server will be available at `http://localhost:3000`

## API Endpoints

The following endpoints are available:

### Users
- `GET /users` - Get all users
- `GET /users/:id` - Get a specific user
- `POST /users` - Create a new user
- `PUT /users/:id` - Update a user
- `PATCH /users/:id` - Partially update a user
- `DELETE /users/:id` - Delete a user

### Drinks (Cocktails)
- `GET /drinks` - Get all cocktails
- `GET /drinks/:id` - Get a specific cocktail
- `POST /drinks` - Create a new cocktail
- `PUT /drinks/:id` - Update a cocktail
- `PATCH /drinks/:id` - Partially update a cocktail
- `DELETE /drinks/:id` - Delete a cocktail

### Bookmarks
- `GET /bookmarks` - Get all bookmarks
- `GET /bookmarks/:id` - Get a specific bookmark
- `POST /bookmarks` - Create a new bookmark
- `DELETE /bookmarks/:id` - Delete a bookmark

### Reviews
- `GET /reviews` - Get all reviews
- `GET /reviews/:id` - Get a specific review
- `POST /reviews` - Create a new review
- `PUT /reviews/:id` - Update a review
- `PATCH /reviews/:id` - Partially update a review
- `DELETE /reviews/:id` - Delete a review

## Query Parameters

json-server supports various query parameters for filtering, sorting, and pagination:

### Filtering
```bash
# Get user by email
GET /users?email=toto@email.com

# Get reviews for a specific drink
GET /reviews?drinkId=dg5e
```

### Sorting
```bash
# Sort users by creation date
GET /users?_sort=createdAt&_order=desc
```

### Pagination
```bash
# Get page 1 with 10 items per page
GET /drinks?_page=1&_limit=10
```

### Full-text Search
```bash
# Search across all fields
GET /drinks?q=gin
```

## Database Structure

The database (`db.json`) contains the following collections:

- **users**: User accounts with authentication credentials and profile information
- **drinks**: Cocktail recipes with ingredients, instructions, and metadata
- **bookmarks**: User-saved cocktail favorites
- **reviews**: User reviews and ratings for cocktails

## Development

### Database File

The database is stored in `db.json`. You can edit this file directly to modify the data. The server will automatically reload when changes are detected.

### Hot Reload

json-server watches the `db.json` file for changes and automatically reloads when modifications are made.

## Notes

- This is a development/mock API and should not be used in production
- Data is persisted to `db.json` and will survive server restarts
- CORS is enabled by default
- The API follows REST conventions

## License

MIT
