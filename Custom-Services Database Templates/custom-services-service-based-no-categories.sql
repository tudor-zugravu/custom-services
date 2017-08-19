-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 19, 2017 at 12:27 AM
-- Server version: 5.7.19-0ubuntu0.16.04.1
-- PHP Version: 7.0.22-0ubuntu0.16.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `custom-services-service-based-no-categories`
--

-- --------------------------------------------------------

--
-- Table structure for table `Corelations`
--

CREATE TABLE `Corelations` (
  `corelation_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `location_id` int(10) NOT NULL,
  `favourite` tinyint(1) NOT NULL DEFAULT '0',
  `rating` int(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Locations`
--

CREATE TABLE `Locations` (
  `location_id` int(10) NOT NULL,
  `latitude` varchar(20) NOT NULL,
  `longitude` varchar(20) NOT NULL,
  `image` varchar(50) DEFAULT NULL,
  `starting_time` time NOT NULL,
  `ending_time` time NOT NULL,
  `vendor_id` int(10) NOT NULL,
  `address` varchar(100) NOT NULL,
  `about` varchar(1000) NOT NULL,
  `rating` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Offers`
--

CREATE TABLE `Offers` (
  `offer_id` int(10) NOT NULL,
  `discount` float NOT NULL,
  `location_id` int(10) NOT NULL,
  `quantity` int(5) NOT NULL DEFAULT '0',
  `appointment_minute_duration` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `Offers`
--
DELIMITER $$
CREATE TRIGGER `set_quantity` BEFORE INSERT ON `Offers` FOR EACH ROW BEGIN
DECLARE duration INT;
DECLARE time_interval INT;

SELECT TIMESTAMPDIFF(MINUTE,starting_time,ending_time)
INTO time_interval
FROM Locations
WHERE location_id = NEW.location_id;

SET duration = NEW.appointment_minute_duration;
SET NEW.quantity = time_interval/duration;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Receipts`
--

CREATE TABLE `Receipts` (
  `receipt_id` int(10) NOT NULL,
  `offer_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `amount` int(5) NOT NULL,
  `rating` int(1) DEFAULT NULL,
  `appointment_starting` int(3) NOT NULL DEFAULT '0',
  `redeemed` int(1) NOT NULL DEFAULT '0',
  `purchase_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `System`
--

CREATE TABLE `System` (
  `system_id` int(10) NOT NULL,
  `type` varchar(10) NOT NULL,
  `main_colour` varchar(6) NOT NULL,
  `opaque_colour` varchar(6) NOT NULL,
  `background_colour` varchar(6) NOT NULL,
  `cell_background_colour` varchar(6) NOT NULL,
  `main_logo` varchar(50) NOT NULL,
  `main_title` varchar(50) NOT NULL,
  `main_tab_logo` varchar(50) NOT NULL,
  `main_tab_title` varchar(20) NOT NULL,
  `geolocation_notifications` tinyint(1) NOT NULL DEFAULT '0',
  `navigation_logo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(30) NOT NULL,
  `profile_picture` varchar(50) DEFAULT NULL,
  `credit` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Vendors`
--

CREATE TABLE `Vendors` (
  `vendor_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `logo_image` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Corelations`
--
ALTER TABLE `Corelations`
  ADD PRIMARY KEY (`corelation_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `Locations`
--
ALTER TABLE `Locations`
  ADD PRIMARY KEY (`location_id`),
  ADD KEY `vendor_id` (`vendor_id`);

--
-- Indexes for table `Offers`
--
ALTER TABLE `Offers`
  ADD PRIMARY KEY (`offer_id`),
  ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `Receipts`
--
ALTER TABLE `Receipts`
  ADD PRIMARY KEY (`receipt_id`),
  ADD KEY `offer_id` (`offer_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `System`
--
ALTER TABLE `System`
  ADD PRIMARY KEY (`system_id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `Vendors`
--
ALTER TABLE `Vendors`
  ADD PRIMARY KEY (`vendor_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Corelations`
--
ALTER TABLE `Corelations`
  MODIFY `corelation_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `Locations`
--
ALTER TABLE `Locations`
  MODIFY `location_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `Offers`
--
ALTER TABLE `Offers`
  MODIFY `offer_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `Receipts`
--
ALTER TABLE `Receipts`
  MODIFY `receipt_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT for table `System`
--
ALTER TABLE `System`
  MODIFY `system_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;
--
-- AUTO_INCREMENT for table `Vendors`
--
ALTER TABLE `Vendors`
  MODIFY `vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `Corelations`
--
ALTER TABLE `Corelations`
  ADD CONSTRAINT `corelations_locations_fk` FOREIGN KEY (`location_id`) REFERENCES `Locations` (`location_id`),
  ADD CONSTRAINT `corelations_users_fk` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`);

--
-- Constraints for table `Locations`
--
ALTER TABLE `Locations`
  ADD CONSTRAINT `locations_vendors_fk` FOREIGN KEY (`vendor_id`) REFERENCES `Vendors` (`vendor_id`);

--
-- Constraints for table `Offers`
--
ALTER TABLE `Offers`
  ADD CONSTRAINT `offers_locations_fk` FOREIGN KEY (`location_id`) REFERENCES `Locations` (`location_id`);

--
-- Constraints for table `Receipts`
--
ALTER TABLE `Receipts`
  ADD CONSTRAINT `receipts_offers_fk` FOREIGN KEY (`offer_id`) REFERENCES `Offers` (`offer_id`),
  ADD CONSTRAINT `receipts_users_fk` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
