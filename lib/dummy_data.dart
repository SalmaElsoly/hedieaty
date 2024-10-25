final users = [
  {
    "id": 1,
    "username": "alice",
    "phoneNumber": "+1234567890",
    "preferences": ["music", "travel"]
  },
  {
    "id": 2,
    "username": "bob",
    "phoneNumber": "+1234567891",
    "preferences": ["books", "tech"]
  },
  {
    "id": 3,
    "username": "carol",
    "phoneNumber": "+1234567892",
    "preferences": ["fitness", "cooking"]
  },
  {
    "id": 4,
    "username": "dave",
    "phoneNumber": "+1234567893",
    "preferences": ["travel", "sports"]
  },
  {
    "id": 5,
    "username": "eve",
    "phoneNumber": "+1234567894",
    "preferences": ["fashion", "music"]
  },
];

// Events Data
final events = [
  {
    "id": 1,
    "name": "Alice's Birthday",
    "date": "2024-05-15",
    "location": "Alice's House",
    "description": "Celebrating Alice's 25th birthday.",
    "userId": 1
  },
  {
    "id": 2,
    "name": "Tech Conference",
    "date": "2024-07-22",
    "location": "Downtown Conference Center",
    "description": "Annual tech industry conference.",
    "userId": 1
  },
  {
    "id": 3,
    "name": "Cooking Workshop",
    "date": "2024-09-10",
    "location": "Community Center",
    "description": "Learn to cook with Carol.",
    "userId": 3
  },
  {
    "id": 4,
    "name": "Football Match",
    "date": "2024-11-05",
    "location": "City Stadium",
    "description": "Friendly football match.",
    "userId": 4
  },
  {
    "id": 5,
    "name": "Music Festival",
    "date": "2024-12-31",
    "location": "Central Park",
    "description": "End of year music festival.",
    "userId": 5
  },
];

// Gifts Data with status as unpledged, pledged, and purchased
final gifts = [
  {
    "id": 1,
    "name": "Wireless Headphones",
    "description": "Noise-cancelling over-ear headphones.",
    "category": "Electronics",
    "price": 89.99,
    "status": "unpledged",
    "eventId": 1
  },
  {
    "id": 2,
    "name": "Python Programming Book",
    "description": "A beginner's guide to Python.",
    "category": "Books",
    "price": 25.50,
    "status": "pledged",
    "eventId": 2
  },
  {
    "id": 3,
    "name": "Chef's Knife Set",
    "description": "Professional-grade kitchen knives.",
    "category": "Kitchen",
    "price": 45.75,
    "status": "purchased",
    "eventId": 3
  },
  {
    "id": 4,
    "name": "Football Jersey",
    "description": "Home jersey of the local football team.",
    "category": "Sportswear",
    "price": 35.00,
    "status": "unpledged",
    "eventId": 4
  },
  {
    "id": 5,
    "name": "Festival Pass",
    "description": "All-access pass for the music festival.",
    "category": "Tickets",
    "price": 120.00,
    "status": "pledged",
    "eventId": 5
  },
];

// Friends Data
final friends = [
  {"userId": 1, "friendId": 2},
  {"userId": 1, "friendId": 3},
  {"userId": 1, "friendId": 4},
  {"userId": 1, "friendId": 5},
  {"userId": 2, "friendId": 1},
  {"userId": 2, "friendId": 3},
  {"userId": 2, "friendId": 4},
  {"userId": 3, "friendId": 5},
  {"userId": 4, "friendId": 1},
  {"userId": 5, "friendId": 2},
];
