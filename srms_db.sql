-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 10, 2026 at 06:15 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `srms_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `event_participants`
--

CREATE TABLE `event_participants` (
  `reservation_id` int(11) NOT NULL,
  `participant_id` varchar(50) NOT NULL,
  `rsvp_status` varchar(20) NOT NULL DEFAULT 'Yes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event_participants`
--

INSERT INTO `event_participants` (`reservation_id`, `participant_id`, `rsvp_status`) VALUES
(4, '4D19EAF4', 'hadir'),
(5, '826F0F4E', 'hadir'),
(5, '98A1F299', 'hadir'),
(5, 'A36C71BF', 'hadir'),
(6, 'DE56C582', 'hadir'),
(7, '54BCD20F', 'tak hadir'),
(7, 'EABDDA3E', 'hadir');

-- --------------------------------------------------------

--
-- Table structure for table `halls`
--

CREATE TABLE `halls` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `capacity` int(11) NOT NULL,
  `location` varchar(150) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Available'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `halls`
--

INSERT INTO `halls` (`id`, `name`, `capacity`, `location`, `status`) VALUES
(1, 'dewan sultan mizan', 40, 'Level 2', 'Available'),
(2, 'Dewan serbaguna umt', 50, 'UMTCC', 'Available');

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone_num` varchar(20) DEFAULT NULL,
  `email_address` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `participants`
--

INSERT INTO `participants` (`id`, `name`, `phone_num`, `email_address`) VALUES
('4D19EAF4', 'ali', '013-9998080', 'ali@gmail.com'),
('54BCD20F', 'MUHAMMAD AFIQ', '019-8888888', 'aimanppe8@gmail.com'),
('826F0F4E', 'Ahmad', '013-565678', 'ahmad@gmail.com'),
('98A1F299', 'MUHAMMAD AIMAN', '019-7819247', 'aimanppe8@gmail.com'),
('A36C71BF', 'Muhammad Amin', '013-5471274', 'doodle@gmail.com'),
('DE56C582', 'Abu samah', '012-2236789', 'samah@gmail.com'),
('EABDDA3E', 'Muhammad Abbas', '014-4441241', 'abbas123@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `reservations`
--

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL,
  `event_name` varchar(150) NOT NULL,
  `event_description` text DEFAULT NULL,
  `reservation_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `hall_id` int(11) DEFAULT NULL,
  `user_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reservations`
--

INSERT INTO `reservations` (`id`, `event_name`, `event_description`, `reservation_date`, `start_time`, `end_time`, `hall_id`, `user_id`) VALUES
(3, 'Hari Buku UMT', 'jualan buku', '2026-06-09', '18:00:00', '19:00:00', 1, 'cust01'),
(4, 'jual jual', 'jual', '2026-06-10', '22:46:00', '23:00:00', 1, 'cust01'),
(5, 'Hari Buku UMT2', 'ggg', '2026-06-17', '10:56:00', '11:57:00', 2, 'cust01'),
(6, 'Ceramah ', 'ceramah maulidur rasul', '2026-06-18', '08:00:00', '09:30:00', 2, 'User02'),
(7, 'Minggu Ilmu Umt', 'karnival ilmu umt', '2026-06-12', '10:40:00', '12:40:00', 2, 'NAQ');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `password`, `name`, `role`) VALUES
('cust01', 'cust123', 'Amirul Asraf', 'customer'),
('NAQ', 'naq123', 'MUHAMMAD NAQIB', 'customer'),
('staff01', 'staff123', 'Encik Ahmad Dani', 'staff'),
('User02', 'aiman123', 'MUHAMMAD AIMAN', 'customer');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `event_participants`
--
ALTER TABLE `event_participants`
  ADD PRIMARY KEY (`reservation_id`,`participant_id`),
  ADD KEY `participant_id` (`participant_id`);

--
-- Indexes for table `halls`
--
ALTER TABLE `halls`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hall_id` (`hall_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `halls`
--
ALTER TABLE `halls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `event_participants`
--
ALTER TABLE `event_participants`
  ADD CONSTRAINT `event_participants_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `event_participants_ibfk_2` FOREIGN KEY (`participant_id`) REFERENCES `participants` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`hall_id`) REFERENCES `halls` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
