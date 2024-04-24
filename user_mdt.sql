CREATE TABLE `user_med_mdt` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`mugshot_url` varchar(255) DEFAULT NULL,
	`bail` bit DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `user_med_convictions` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`offense` varchar(255) DEFAULT NULL,
	`count` int(11) DEFAULT NULL,
	
	PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_reports` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`char_id` int(11) DEFAULT NULL,
	`title` varchar(255) DEFAULT NULL,
	`incident` longtext DEFAULT NULL,
    `charges` longtext DEFAULT NULL,
    `author` varchar(255) DEFAULT NULL,
	`name` varchar(255) DEFAULT NULL,
    `date` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_warrants` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(255) DEFAULT NULL,
	`char_id` int(11) DEFAULT NULL,
	`report_id` int(11) DEFAULT NULL,
	`report_title` varchar(255) DEFAULT NULL,
	`charges` longtext DEFAULT NULL,
	`date` varchar(255) DEFAULT NULL,
	`expire` varchar(255) DEFAULT NULL,
	`notes` varchar(255) DEFAULT NULL,
	`author` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `med_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `jailtime` int(11) DEFAULT NULL,
	
       PRIMARY KEY (`id`)
);

CREATE TABLE `mdt_med_notes` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`title` varchar(255) DEFAULT NULL,
	`incident` longtext DEFAULT NULL,
    `author` varchar(255) DEFAULT NULL,
    `date` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `med_types` (`id`, `label`, `amount`, `category`, `jailtime`) VALUES
(1, 'Fractura de brazo izquierdo', 0, 0, 0),
(2, 'Fractura de brazo derecho', 0, 0, 0),
(3, 'Fractura de pierna izquierda', 0, 0, 0),
(4, 'Fractura de pierna derecha', 0, 0, 0),
(5, 'Fractura de nariz', 0, 0, 0),
(6, 'Herida de bala en el brazo', 0, 0, 0),
(7, 'Herida de bala en la pierna', 0, 0, 0),
(8, 'Herida de bala en el torso', 0, 0, 0),
(9, 'Herida de bala en la parte inferior del cuerpo', 0, 0, 0),
(10, 'Lesión en la cabeza', 0, 0, 0),
(11, 'Resfriado', 0, 0, 0),
(12, 'Cólera', 0, 0, 0),
(13, 'Malaria', 0, 0, 0),
(14, 'Corte', 0, 0, 0),
(15, 'Contusión', 0, 0, 0),
(16, 'Enfermedad de la piel', 0, 0, 0),
(17, 'Síntomas generales de dolor', 0, 0, 0),
(18, 'Otras dolencias', 0, 0, 0);

