CREATE TABLE `users` (
	`id` INT NOT NULL,
	`display_name` varchar NOT NULL,
	`username` varchar NOT NULL,
	`email` varchar NOT NULL,
	`pass_digest` varchar NOT NULL,
	`access_token` varchar NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `devices` (
	`id` INT NOT NULL,
	`name` varchar NOT NULL UNIQUE,
	`location` varchar NOT NULL,
	`description` TEXT NOT NULL,
	`access_token` varchar NOT NULL,
	`contact_at` TIMESTAMP NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `groups` (
	`id` INT NOT NULL,
	`name` varchar NOT NULL,
	`location` varchar NOT NULL,
	`description` TEXT NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `group_device_user` (
	`user_id` INT NOT NULL UNIQUE,
	`group_id` INT NOT NULL UNIQUE,
	`device_id` INT NOT NULL UNIQUE
);

CREATE TABLE `device_properties` (
	`id` INT NOT NULL,
	`device_id` INT NOT NULL UNIQUE,
	`name` varchar NOT NULL UNIQUE,
	`auto_mode` bool NOT NULL,
	`property_type` varchar NOT NULL,
	`value_type` varchar NOT NULL,
	`value_min` varchar NOT NULL,
	`value_max` varchar NOT NULL,
	`???property_values???` varchar NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `value_types` (
	`types` varchar(20) NOT NULL UNIQUE
);

CREATE TABLE `property_types` (
	`types` varchar NOT NULL UNIQUE
);

CREATE TABLE `schedule` (
	`id` INT NOT NULL,
	`user_id` INT NOT NULL,
	`schedule_mode` varchar NOT NULL,
	`schedule_type` varchar NOT NULL,
	`schedule_type_id` INT NOT NULL,
	`interval_time` TIME NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `schedule_points` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`schedule_id` INT NOT NULL,
	`name` varchar NOT NULL,
	`time` TIMESTAMP NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `schedule_point_settings` (
	`schedule_point_id` INT NOT NULL,
	`property_id` INT NOT NULL,
	`property_value` varchar NOT NULL
);

CREATE TABLE `quick_buttons` (
	`id` INT NOT NULL,
	`user_id` INT NOT NULL,
	`device_id` INT NOT NULL,
	`name` varchar NOT NULL,
	`schedule_id` INT NOT NULL,
	PRIMARY KEY (`id`)
);

ALTER TABLE `group_device_user` ADD CONSTRAINT `group_device_user_fk0` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`);

ALTER TABLE `group_device_user` ADD CONSTRAINT `group_device_user_fk1` FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`);

ALTER TABLE `group_device_user` ADD CONSTRAINT `group_device_user_fk2` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`);

ALTER TABLE `device_properties` ADD CONSTRAINT `device_properties_fk0` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`);

ALTER TABLE `device_properties` ADD CONSTRAINT `device_properties_fk1` FOREIGN KEY (`property_type`) REFERENCES `property_types`(`types`);

ALTER TABLE `device_properties` ADD CONSTRAINT `device_properties_fk2` FOREIGN KEY (`value_type`) REFERENCES `value_types`(`types`);

ALTER TABLE `schedule_points` ADD CONSTRAINT `schedule_points_fk0` FOREIGN KEY (`schedule_id`) REFERENCES `schedule`(`id`);

ALTER TABLE `schedule_point_settings` ADD CONSTRAINT `schedule_point_settings_fk0` FOREIGN KEY (`schedule_point_id`) REFERENCES `schedule_points`(`id`);

ALTER TABLE `quick_buttons` ADD CONSTRAINT `quick_buttons_fk0` FOREIGN KEY (`schedule_id`) REFERENCES `schedule`(`id`);

