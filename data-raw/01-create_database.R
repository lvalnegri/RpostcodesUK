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
    OA CHAR(9) NOT NULL COMMENT 'Output Area 2021 (EW) + 2011 (NS) (E00, W00, S00, N00)',
    OA11 CHAR(9) NOT NULL COMMENT 'Output Area 2011 (E00, W00, S00, N00)',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector',
    WPZ CHAR(9) NOT NULL COMMENT 'Workplace Zone (E33, N19, S34, W35)',
    PRIMARY KEY (PCU),
    INDEX (is_active),
    INDEX (usertype),
    INDEX (OA),
    INDEX (OA11),
    INDEX (PCS),
    INDEX (RGN),
    INDEX (CTRY),
    INDEX (WPZ)
"
dd_create_dbtable('postcodes', dbn, x)

# OUTPUT AREAS --------------
x <- "
    OA CHAR(9) NOT NULL COMMENT 'Output Area 2021 (EW) + 2011 (NS) (E00, W00, S00, N00)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector',
    PCD CHAR(4) NULL DEFAULT NULL COMMENT 'PostCode District',
    PCT CHAR(5) NULL DEFAULT NULL COMMENT 'Post Town (internal code, see `pzones` for more info)',
    PCA CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Area',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    RGNd CHAR(9) NULL DEFAULT NULL COMMENT 'Description for Region',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PRIMARY KEY (OA),
    INDEX (PCS),
    INDEX (PCD),
    INDEX (PCT),
    INDEX (PCA),
    INDEX (RGN),
    INDEX (CTRY)
"
dd_create_dbtable('output_areas', dbn, x)

# POSTAL --------------------
x <- "
    PCS CHAR(5) NOT NULL COMMENT 'PostCode Sector',
    PCD CHAR(4) NOT NULL COMMENT 'PostCode District',
    PCT CHAR(5) NOT NULL COMMENT 'Post Town (internal code, see `pzones` for more info)',
    PCA CHAR(5) NOT NULL COMMENT 'PostCode Area',
    RGN CHAR(9) NOT NULL COMMENT 'Region',
    PRIMARY KEY (PCS),
    INDEX (PCD),
    INDEX (PCT),
    INDEX (PCA),
    INDEX (RGN)
"
dd_create_dbtable('postal', dbn, x)

# PZONES --------------------
x <- "
    type CHAR(4) NOT NULL,
    code CHAR(9) NOT NULL,
    name CHAR(75) NOT NULL,
    parent CHAR(9) NULL,
    country CHAR(1) NOT NULL,
    ordering SMALLINT(4) UNSIGNED NOT NULL,
    area INT(10) UNSIGNED NOT NULL,
    perimeter MEDIUMINT(8) UNSIGNED NOT NULL,
    x_lon DECIMAL(8,6) NOT NULL COMMENT 'longitude for the Geometric Centroid',
    y_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude for the Geometric Centroid',
    wx_lon DECIMAL(8,6) NOT NULL COMMENT 'longitude for the Population Weigthed centroid',
    wy_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude for the Population Weigthed centroid',
    px_lon DECIMAL(8,6) NOT NULL COMMENT 'longitude for the Pole of inaccessibility',
    py_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude for the Pole of inaccessibility',
    bb_xmin DECIMAL(8,6) NOT NULL COMMENT 'longitude for the SW corner of the Bounding Box for the Zone',
    bb_ymin DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude for the SW corner of the Bounding Box for the Zone',
    bb_xmax DECIMAL(8,6) NOT NULL COMMENT 'longitude for the NE corner of the Bounding Box for the Zone',
    bb_ymax DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude for the NE corner of the Bounding Box for the Zone',
    PRIMARY KEY (type, code),
    INDEX type (ordering),
    INDEX parent (parent),
    INDEX country (country)
"
dd_create_dbtable('pzones', dbn, x)

# NEIGHBOURS ----------------
x = "
    type CHAR(3) NOT NULL,
    idA CHAR(9) NOT NULL,
    idB CHAR(9) NOT NULL,
    PRIMARY KEY (type, idA, idB)
"
dd_create_dbtable('neighbours', dbn, x)

# MISSING_OA ----------------
x = "
    census SMALLINT(4) UNSIGNED NOT NULL,
    OA CHAR(9) NOT NULL,
    PCS CHAR(5) NOT NULL
"
dd_create_dbtable('missing_oa', dbn, x)

# MISSING_PCS ---------------
x = "
    CTRY CHAR(1) NOT NULL,
    PCU CHAR(7) NOT NULL,
    is_active TINYINT(1) UNSIGNED NOT NULL,
    usertype TINYINT(1) UNSIGNED NOT NULL,
    x_lon DECIMAL(7,6) NOT NULL,
    y_lat DECIMAL(8,6) UNSIGNED NOT NULL,
    OA CHAR(9) NOT NULL,
    OA11 CHAR(9) NOT NULL,
    RGN CHAR(9) NOT NULL,
    WPZ CHAR(9) NOT NULL,
    PCS CHAR(5) NOT NULL,
    PRIMARY KEY (PCU),
    INDEX (is_active),
    INDEX (usertype),
    INDEX (OA),
    INDEX (OA11),
    INDEX (PCS),
    INDEX (RGN),
    INDEX (CTRY),
    INDEX (WPZ)
"
dd_create_dbtable('missing_pcs', dbn, x)

# PCS_REGIONS ---------------
x = "
    PCS CHAR(5) NOT NULL,
    RGN CHAR(9) NOT NULL
"
dd_create_dbtable('pcs_regions', dbn, x)

# PCS_LINKAGE ---------------
x = "
    `PCS.old` CHAR(5) NOT NULL,
    PCS CHAR(5) NOT NULL
"
dd_create_dbtable('pcs_linkage', dbn, x)

# PCD_LINKAGE ---------------
x = "
    `PCD.old` CHAR(4) NOT NULL,
    PCD CHAR(4) NOT NULL
"
dd_create_dbtable('pcd_linkage', dbn, x)

# PCA_TOTALS ----------------
x = "
    PCA CHAR(8) NOT NULL,
    PCD SMALLINT UNSIGNED NOT NULL,
    PCS SMALLINT UNSIGNED NOT NULL,
    live MEDIUMINT UNSIGNED NOT NULL,
    `terminated` MEDIUMINT UNSIGNED NOT NULL,
    total MEDIUMINT UNSIGNED NOT NULL
"
dd_create_dbtable('pca_totals', dbn, x)

# PCS_NON_GEO ---------------
dd_create_dbtable('pcs_non_geo', dbn, "PCS CHAR(5) NOT NULL")

rm(list = ls())
gc()
