ALTER TABLE uni1_config
ADD `google_on` tinyint(1) NOT NULL DEFAULT 0,
ADD `google_apikey` varchar(100) NOT NULL DEFAULT '',
ADD `google_skey` varchar(42) NOT NULL DEFAULT '';