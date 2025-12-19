# 🍹 Cocktails App

A modern iOS application for discovering, exploring, and reviewing cocktails. Built with SwiftUI and integrating TheCocktailDB API with a local json-server backend.

## ✨ Features

### 🔍 Browse & Discover
- **Extensive Cocktail Database**: Access to 550+ cocktails from TheCocktailDB
- **Smart Search**: Search by cocktail name, ingredients, or description
- **Advanced Filtering**: Filter by category, difficulty, alcohol content, and tags
- **Alphabetical Sorting**: All cocktails sorted by title for easy navigation

### 📱 User Experience
- **Detailed Cocktail Views**: 
  - High-quality images
  - Complete ingredient lists with measurements
  - Step-by-step instructions
  - Nutritional information (prep time, difficulty, glass type)
  - Collapsible sections for better readability

### ⭐ Ratings & Reviews
- **User Reviews**: Read and write reviews for cocktails
- **Rating System**: 5-star rating with half-star precision
- **Rating Distribution**: Visual breakdown of all ratings
- **Edit Reviews**: Update your own reviews anytime
- **Author Information**: See who reviewed each cocktail

### 🔖 Bookmarks
- **Save Favorites**: Bookmark cocktails for quick access
- **Persistent Storage**: Bookmarks synced across sessions
- **Easy Management**: Quick add/remove from detail view

### 🔄 Data Synchronization
- **Automatic Sync**: First-time sync from TheCocktailDB on app launch
- **Manual Refresh**: Sync button for updating cocktail database
- **Smart Updates**: Only syncs when database is empty or outdated
- **Progress Tracking**: Visual feedback during sync operations

### 👤 Authentication
- **User Accounts**: Secure login and registration
- **Profile Management**: View and edit user profiles
- **Personalized Experience**: User-specific bookmarks and reviews

## 🏗️ Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Reactive Programming**: SwiftUI with Combine framework
- **Dependency Injection**: Service-based architecture

### Key Components

#### Models
- `Cocktail`: Local cocktail model with all details
- `Drink`: TheCocktailDB API response model
- `Review`: User review with rating and comment
- `User`: User account information
- `Bookmark`: Saved cocktail references

#### ViewModels
- `CocktailListViewModel`: Manages cocktail list, search, and filters
- `ReviewListViewModel`: Handles review fetching and management
- `ReviewViewModel`: Manages review creation and editing

#### Services
- `CocktailAPIService`: Local json-server API client
- `CocktailService`: TheCocktailDB API client
- `CocktailDataService`: Unified data sync orchestrator
- `CocktailMapper`: Maps external API data to local models
- `AuthManager`: User authentication and session management

#### Views
- `CocktailListView`: Main cocktail grid with filters
- `CocktailDetailView`: Detailed cocktail information
- `ReviewsListView`: Review listing and submission
- `BookmarksView`: User's saved cocktails
- `ProfileView`: User profile management

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+**: Latest version with SwiftUI support
- **iOS 17+**: Target deployment
- **Node.js**: For running json-server backend
- **pnpm**: Package manager (or npm/yarn)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CocktailsApp
   ```

2. **Install backend dependencies**
   ```bash
   cd api
   pnpm install
   ```

3. **Start the json-server**
   ```bash
   pnpm api
   ```
   Server runs on `http://localhost:4000`

4. **Open the Xcode project**
   ```bash
   cd ../CocktailsApp
   open CocktailsApp.xcodeproj
   ```

5. **Run the app**
   - Select a simulator or device
   - Press `⌘ + R` to build and run
   - On first launch, the app will automatically sync cocktails from TheCocktailDB

## 🔗 API Integration

### Dual API Architecture

The app uses two APIs working together:

1. **TheCocktailDB (External)**
   - **URL**: `https://www.thecocktaildb.com/api/json/v1/1/`
   - **Purpose**: Source of cocktail data
   - **Usage**: Read-only, fetched during sync
   - **Data**: 550+ cocktails with full details

2. **json-server (Local)**
   - **URL**: `http://localhost:4000`
   - **Purpose**: Local database and user data
   - **Endpoints**:
     - `/drinks` - Cocktail data (synced from TheCocktailDB)
     - `/users` - User accounts
     - `/reviews` - User reviews and ratings
     - `/bookmarks` - Saved cocktails

### Data Flow

```
TheCocktailDB → CocktailDataService → json-server → App Views
                     ↓
                CocktailMapper
                (maps Drink to Cocktail)
```

### Sync Process

1. App checks if sync is needed (empty DB or 24hrs old)
2. Fetches all cocktails from TheCocktailDB (a-z)
3. Maps external `Drink` model to local `Cocktail` model
4. Upserts into local json-server database
5. App uses local data for all operations

## 🛠️ Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming
- **URLSession**: Networking
- **AsyncImage**: Image loading and caching
- **json-server**: RESTful API mock server
- **TheCocktailDB API**: External cocktail database

## 📁 Project Structure

```
CocktailsApp/
├── Models/
│   ├── Cocktail.swift              # Local cocktail model
│   └── TheCoctailDrinkAPI.swift    # External API model
├── ViewModels/
│   ├── CocktailListViewModel.swift
│   ├── ReviewViewModel.swift
│   └── ReviewListViewModel.swift
├── Views/
│   ├── CocktailListView.swift      # Main list with filters
│   ├── CocktailDetailView.swift    # Detailed view
│   ├── ReviewsListView.swift       # Reviews page
│   ├── BookmarksView.swift         # Saved cocktails
│   ├── ProfileView.swift           # User profile
│   └── MainTabView.swift           # Tab navigation
├── Services/
│   ├── CocktailAPIService.swift    # Local API client
│   ├── TheCocktailDinkAPIService.swift # External API client
│   ├── CocktailDataService.swift   # Sync orchestrator
│   ├── CocktailMapper.swift        # Data mapping
│   └── AuthManager.swift           # Authentication
└── Assets.xcassets/

api/
├── db.json                         # json-server database
├── package.json
└── README.md
```

## 🎨 Features in Detail

### Filtering System
- **Flow Layout**: Chips automatically wrap to multiple lines
- **Multiple Filters**: Combine category, difficulty, alcohol, and tags
- **Active Indicators**: See applied filters at a glance
- **Quick Reset**: Clear all filters with one tap

### Review System
- **Star Ratings**: 1-5 stars with decimal precision
- **Comments**: Optional text feedback
- **Edit Capability**: Update your own reviews
- **Author Attribution**: Know who reviewed what
- **Relative Timestamps**: "2 hours ago" format

### Sync Features
- **Concurrent Fetching**: Parallel API calls for speed
- **Progress Tracking**: Real-time progress updates
- **Error Handling**: Graceful error recovery
- **Console Logging**: Detailed sync information

## 🔒 User Permissions

### Read-Only (All Users)
- ✅ Browse cocktails
- ✅ View details
- ✅ Search and filter

### Authenticated Users
- ✅ Add/edit reviews
- ✅ Rate cocktails
- ✅ Bookmark favorites
- ✅ Manage profile

### System Only
- 🔒 Create/update cocktails (via sync)
- 🔒 Modify cocktail data

## 🐛 Troubleshooting

### json-server not starting
```bash
# Kill process on port 4000
lsof -ti:4000 | xargs kill -9
# Restart server
pnpm api
```

### Cocktails not loading
- Check json-server is running on port 4000
- Tap sync button to fetch from TheCocktailDB
- Check Xcode console for error messages

### Images not loading
- Verify internet connection
- TheCocktailDB images require network access
- Check image URLs in console

## 📝 Development

### Adding New Features
1. Create model in `Models/`
2. Add service methods in `Services/`
3. Create ViewModel in `ViewModels/`
4. Build View in `Views/`
5. Update navigation if needed

### Testing Sync
```bash
# View sync logs in console
# Look for these indicators:
# 🔍 Checking if sync needed...
# 📡 Starting to fetch drinks...
# 📊 Progress: X/26 letters
# ✅ Successfully synced
```

## 📄 License

This project is for educational purposes.

## 🙏 Acknowledgments

- **TheCocktailDB**: Free cocktail database API
- **json-server**: Simple local REST API
- **SwiftUI**: Apple's declarative UI framework

---

Built with ❤️ using SwiftUI
