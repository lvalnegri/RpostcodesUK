###########################################################
# UK GEOGRAPHY * 01 - Create database and tables in MySQL #
###########################################################

library(Rfuns)

dbn <- 'postcodes_uk'

dd_create_db(dbn)

# POSTCODES -----------------
x <- "
    PCU CHAR(7) NOT NULL COMMENT 'Postcode Unit in 7-chars format: 4-chars outcode + 3-chars incode',
    is_active TINYINT(1) UNSIGNED NOT NULL COMMENT 'Flag that indicates if the corresponding PCU is currently active (0) or *terminated* (1)',
    is_nongeo TINYINT(1) UNSIGNED NOT NULL 
        COMMENT '*Non-Geographic codes*, while still connected to a geographic location, are only used for routing, direct marketing or PO boxes, and 
                 should not be used for navigation, estimating distances, or any other spatial (GIS) purpose, as they are often linked to non-physical addresses.',
    is_valid TINYINT(1) UNSIGNED NOT NULL COMMENT 'Flag that indicates if the corresponding PCU is (1) a correct geographic entity AND currently active',
    is_large TINYINT(1) UNSIGNED NOT NULL COMMENT 'Flag that indicate if the corresponding PCU relate to a `large user`, with more than 25 items per day',
    pqi TINYINT(1) UNSIGNED NOT NULL COMMENT 'see the table `pqi` for descriptions of values',
    Easting MEDIUMINT UNSIGNED NOT NULL COMMENT '1m grid reference North-wide using British National Grid (EPSG 27700) for Great Britain and Irish Grid (EPSG ) for N.Ireland',
    Northing MEDIUMINT UNSIGNED NOT NULL COMMENT '1m grid reference East-wide using British National Grid (EPSG 27700) for Great Britain and Irish Grid (EPSG ) for N.Ireland',
    x_lon DECIMAL(7,6) NOT NULL COMMENT 'Geographic longitude of the 1m Easting using the WGS84 Reference System (EPSG 4326)',
    y_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'Geographic latitude of the 1m Northing using the WGS84 Reference System (EPSG 4326)',
    OA CHAR(9) NOT NULL COMMENT 'Output Area 2021 (EWN) + 2011 (S) (E00, W00, S00, N00)',
    OA11 CHAR(9) NOT NULL COMMENT 'Output Area 2011 (E00, W00, S00, N00)',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector (see the table `postal` for the higher levels of the postal hierarchy)',
    WPZ CHAR(9) NOT NULL COMMENT 'Workplace Zone (E33, N19, S34, W35)',
    PRIMARY KEY (PCU),
    INDEX (is_active),
    INDEX (usertype),
    INDEX (pqi),
    INDEX (is_nongeo),
    INDEX (OA),
    INDEX (OA11),
    INDEX (PCS),
    INDEX (RGN),
    INDEX (CTRY),
    INDEX (WPZ)
"
dd_create_dbtable('postcodes', dbn, x)

# PQI -----------------------
x <- "
    pqi TINYINT(1) UNSIGNED NOT NULL COMMENT 'PQI Positional Quality Indicator denotes the accuracy of the grid reference of a PCU',
    description CHAR(100) NOT NULL,
    N MEDIUMINT UNSIGNED DEFAULT NULL COMMENT 'Count at last pubblication',
    PRIMARY KEY (pqi)
"
y <- fread('./data-raw/csv/pqi.csv')
dd_create_dbtable('pqi', dbn, x, y)

# OUTPUT AREAS --------------
x <- "
    OA CHAR(9) NOT NULL COMMENT 'Output Area (2021 Census for England, Wales, and N.Ireland; 2011 Census for Scotland)',
    LSOA CHAR(9) NOT NULL COMMENT 'Lower Layer Super Output Area (2021 Census for England, Wales, and N.Ireland; 2011 Census for Scotland)',
    MSOA CHAR(9) NULL DEFAULT NULL COMMENT 'Middle Layer Super Output Area (2021 Census for England and Wales; 2011 Census for Scotland; there are no MSOAs for N.Ireland)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector (Postal)',
    PCD CHAR(4) NULL DEFAULT NULL COMMENT 'PostCode District (Postal)',
    PCT CHAR(5) NULL DEFAULT NULL COMMENT 'Post Town (internal code, see `pzones` for more info) (Postal)',
    PCA CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Area (Postal)',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    RGNd CHAR(9) NULL DEFAULT NULL COMMENT 'Description for Region',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PRIMARY KEY (OA),
    INDEX (LSOA),
    INDEX (MSOA),
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

# CZONES --------------------
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
dd_create_dbtable('czones', dbn, x)

# NEIGHBOURS ----------------
x = "
    type CHAR(3) NOT NULL,
    idA CHAR(5) NOT NULL,
    idB CHAR(5) NOT NULL,
    PRIMARY KEY (type, idA, idB)
"
dd_create_dbtable('neighbours', dbn, x)

# DISTANCES -----------------
x = "
    PCUa CHAR(7) NOT NULL,
    PCUb CHAR(7) NOT NULL,
    distance SMALLINT UNSIGNED NOT NULL,
    knn TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (PCUa, PCUb)
"
dd_create_dbtable('distances', dbn, x)

# NEAREST -------------------
x = "
    PCU CHAR(7) NOT NULL,
    type CHAR(4) NOT NULL,
    code CHAR(9) NOT NULL,
    PRIMARY KEY (PCU, type)
"
dd_create_dbtable('nearest', dbn, x)

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
