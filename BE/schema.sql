-- Streamlined Cultural Meetup App Database Schema
-- Core tables only for location-based cultural exchange app

-- Users table - Core user information
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    profile_picture_url TEXT, -- Cloudinary URL: https://res.cloudinary.com/your-cloud/image/upload/v1234567890/profiles/user_abc123.jpg
    bio TEXT,
    age INT,
    city VARCHAR(100),
    country VARCHAR(100),
    
    interests TEXT[], -- ["food", "music", "history", "traditions"]
    
    -- Location
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_updated_at TIMESTAMP WITH TIME ZONE,
    
    -- Stats
    total_interactions INT DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
);

-- Connections between users (simplified matching)
CREATE TABLE friends (
    user_id_1 UUID REFERENCES users(id) ON DELETE CASCADE,
    user_id_2 UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_id_1, user_id_2)
);

-- Meetups (actual real-world meetings)
CREATE TABLE meetups (
    connection_id UUID REFERENCES connections(id) ON DELETE CASCADE,
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposed_by UUID REFERENCES users(id) ON DELETE CASCADE,
    location_name VARCHAR(255),
    location_address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    meetup_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'proposed', -- proposed, confirmed, completed, cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Post-meetup reviews (like Uber rating system)
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meetup_id UUID REFERENCES meetups(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES users(id) ON DELETE CASCADE,
        reviewed_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    
    -- Post-meetup photo together
    meetup_photo_url TEXT, -- Cloudinary URL: https://res.cloudinary.com/your-cloud/image/upload/v1234567890/meetups/meetup_abc123.jpg
    meetup_photo_public_id VARCHAR(255), -- For managing the photo: meetups/meetup_abc123

    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(meetup_id, reviewer_id)
);

-- Simple chat messages (just for coordinating meetups)
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    connection_id UUID REFERENCES connections(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message_text TEXT, -- null if message_type is 'image'
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, location, meetup_proposal
    image_url TEXT, -- Cloudinary URL for images: https://res.cloudinary.com/your-cloud/image/upload/v1234567890/chat/msg_xyz789.jpg
    cloudinary_public_id VARCHAR(255), -- For managing/deleting images: chat/msg_xyz789
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
