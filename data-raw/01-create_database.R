###########################################################
# UK GEOGRAPHY * 01 - Create database and tables in MySQL #
###########################################################

library(Rfuns)

dbn <- 'postcodes_uk'

dd_create_db(dbn)

# POSTCODES -----------------
x <- "
    PCU CHAR(7) NOT NULL COMMENT 'postcode in 7-chars format: 4-chars outcode + 3-chars incode',
    is_active TINYINT(1) UNSIGNED NOT NULL,
    usertype TINYINT(1) UNSIGNED NOT NULL COMMENT '0- small user, 1- large user (large means addresses receiving more than 25 items per day)',
    x_lon DECIMAL(7,6) NOT NULL COMMENT 'longitude of the geometric centroid of the postcode',
    y_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude of the geometric centroid of the postcode',
    OA CHAR(9) NOT NULL COMMENT 'Output Area 2011+2021 (E00, W00, S00, N00)',
    OA11 CHAR(9) NOT NULL COMMENT 'Output Area 2011 (E00, W00, S00, N00)',
    OA21 CHAR(9) NOT NULL COMMENT 'Output Area 2021 (E00, W00)',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector (outcode plus 1st digit incode)',
    PCD CHAR(4) NULL DEFAULT NULL COMMENT 'PostCode District',
    PCT CHAR(5) NULL DEFAULT NULL COMMENT 'Post Town (internal code, see `zones` for more info)',
    PCA CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Area',
    WPZ CHAR(9) NOT NULL COMMENT 'Workplace Zone (E33, N19, S34, W35)',
    PRIMARY KEY (PCU),
    INDEX (is_active),
    INDEX (usertype),
    INDEX (OA),
    INDEX (OA21),
    INDEX (PCS),
    INDEX (PCD),
    INDEX (PCT),
    INDEX (PCA),
    INDEX (RGN),
    INDEX (CTRY),
    INDEX (WPZ)
"
dd_create_dbtable('postcodes', dbn, x)

# PZONES -----------------
x <- "
    type CHAR(4) NOT NULL,
    code CHAR(9) NOT NULL,
    name CHAR(75) NOT NULL,
    ordering SMALLINT(3) UNSIGNED NOT NULL,
    PRIMARY KEY (type, code),
    INDEX type (ordering)
"
dd_create_dbtable('pzones', dbn, x)

# NEIGHBOURS ----------------
x = "
    type CHAR(3) NOT NULL
    idA CHAR(9) NOT NULL,
    idB CHAR(9) NOT NULL,
    distance MEDIUMINT(7) UNSIGNED NOT NULL,
    knn SMALLINT(3) UNSIGNED NOT NULL,
    INDEX (idA),
    INDEX (idB)
"
dd_create_dbtable('neighbours', dbn, x)

rm(list = ls())
gc()
