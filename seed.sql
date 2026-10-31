-- =====================================================================
-- Agriculture Information System  -  seed.sql
-- Run LAST (after schema.sql, reports.sql, security.sql) in the
-- Supabase SQL Editor. The editor runs as the table owner, so RLS does
-- not block these inserts.
--
-- Crop, farmer, farm, planting and harvest rows are the sample data from
-- the project brief. Text values in the brief (e.g. "Grade A", "Irrigated",
-- "Harvested") are replaced by the matching lookup ID.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- Lookup values  (OVERRIDING SYSTEM VALUE lets us choose the IDs)
-- ---------------------------------------------------------------------
insert into app_role (role_id, role_name) overriding system value values
  (1, 'Administrator'), (2, 'Staff'), (3, 'Viewer');

insert into crop_category (category_id, category_name) overriding system value values
  (1, 'Cereal'), (2, 'Vegetable'), (3, 'Fruit'), (4, 'Legume'), (5, 'Root Crop');

insert into season (season_id, season_name) overriding system value values
  (1, 'Wet Season'), (2, 'Dry Season'), (3, 'Year Round');

insert into soil_type (soil_type_id, soil_type_name) overriding system value values
  (1, 'Loam'), (2, 'Clay Loam'), (3, 'Sandy Loam'), (4, 'Clay'), (5, 'Silt Loam');

insert into irrigation_type (irrigation_type_id, irrigation_type_name) overriding system value values
  (1, 'Rainfed'), (2, 'Irrigated'), (3, 'Drip Irrigation');

insert into planting_status (status_id, status_name) overriding system value values
  (1, 'Planted'), (2, 'Growing'), (3, 'Harvested'), (4, 'Failed');

insert into quality_grade (grade_id, grade_name) overriding system value values
  (1, 'Grade A'), (2, 'Grade B'), (3, 'Grade C');

-- Exactly the lookup table given in the project brief
insert into harvest_remark (remark_id, remark_description) overriding system value values
  (1, 'Good Harvest'), (2, 'Acceptable Quality'), (3, 'Low Yield'),
  (4, 'Poor Quality'), (5, 'Damaged Harvest');

insert into buyer_type (buyer_type_id, buyer_type_name) overriding system value values
  (1, 'Wholesaler'), (2, 'Retailer'), (3, 'Cooperative'), (4, 'Food Processor'), (5, 'Market Vendor');

insert into input_type (input_type_id, input_type_name) overriding system value values
  (1, 'Inorganic Fertilizer'), (2, 'Organic Fertilizer'), (3, 'Insecticide'),
  (4, 'Fungicide'), (5, 'Herbicide');

insert into unit_of_measure (unit_id, unit_name, unit_code) overriding system value values
  (1, 'Kilogram', 'kg'), (2, 'Liter', 'L'), (3, 'Sack (50 kg)', 'sack');


-- ---------------------------------------------------------------------
-- CROP (10)  category: 1 Cereal 2 Vegetable 3 Fruit 4 Legume 5 Root Crop
--            season:   1 Wet 2 Dry 3 Year Round
-- ---------------------------------------------------------------------
insert into crop (crop_id, crop_name, variety, category_id, growing_period_days, season_id) overriding system value values
  (1,  'Rice',         'NSIC Rc 222',   1, 115, 1),
  (2,  'Corn',         'Yellow Corn',   1, 100, 2),
  (3,  'Tomato',       'Diamante Max',  2,  90, 2),
  (4,  'Eggplant',     'Morena',        2, 100, 3),
  (5,  'Banana',       'Lakatan',       3, 300, 3),
  (6,  'Mango',        'Carabao',       3, 150, 2),
  (7,  'Peanut',       'BPI Pn 9',      4, 110, 2),
  (8,  'Cassava',      'Golden Yellow', 5, 240, 3),
  (9,  'Sweet Potato', 'NSIC Sp 30',    5, 120, 3),
  (10, 'Watermelon',   'Sweet 16',      3,  85, 2);


-- ---------------------------------------------------------------------
-- FARMER (15)
-- ---------------------------------------------------------------------
insert into farmer (farmer_id, first_name, last_name, contact_number, address, date_registered) overriding system value values
  (1,  'Juan',    'Dela Cruz',  '09171234567', 'Cebu City',          '2026-10-26'),
  (2,  'Maria',   'Santos',     '09181234567', 'Carcar City, Cebu',  '2026-10-26'),
  (3,  'Pedro',   'Reyes',      '09191234567', 'Danao City, Cebu',   '2026-10-26'),
  (4,  'Ana',     'Garcia',     '09201234567', 'Argao, Cebu',        '2026-10-26'),
  (5,  'Jose',    'Mendoza',    '09211234567', 'Bogo City, Cebu',    '2026-10-26'),
  (6,  'Ramon',   'Flores',     '09221234567', 'Toledo City, Cebu',  '2026-10-26'),
  (7,  'Elena',   'Cruz',       '09231234567', 'Naga City, Cebu',    '2026-10-26'),
  (8,  'Antonio', 'Lim',        '09241234567', 'Minglanilla, Cebu',  '2026-10-26'),
  (9,  'Rosa',    'Fernandez',  '09251234567', 'Liloan, Cebu',       '2026-10-26'),
  (10, 'Mario',   'Villanueva', '09261234567', 'Compostela, Cebu',   '2026-10-26'),
  (11, 'Teresa',  'Navarro',    '09271234567', 'Talisay City, Cebu', '2026-10-26'),
  (12, 'Carlos',  'Ramos',      '09281234567', 'Consolacion, Cebu',  '2026-10-26'),
  (13, 'Liza',    'Torres',     '09291234567', 'Dalaguete, Cebu',    '2026-10-26'),
  (14, 'Roberto', 'Castillo',   '09301234567', 'Barili, Cebu',       '2026-10-26'),
  (15, 'Susan',   'Aquino',     '09311234567', 'Sibonga, Cebu',      '2026-10-26');


-- ---------------------------------------------------------------------
-- FARM (15)  soil: 1 Loam 2 Clay Loam 3 Sandy Loam 4 Clay
--            irrigation: 1 Rainfed 2 Irrigated 3 Drip Irrigation
-- ---------------------------------------------------------------------
insert into farm (farm_id, farmer_id, farm_name, location, area_hectares, soil_type_id, irrigation_type_id) overriding system value values
  (1,  1,  'Dela Cruz Farm',            'Cebu City',          2.50, 1, 1),
  (2,  2,  'Santos Rice Farm',          'Carcar City, Cebu',  4.20, 2, 2),
  (3,  3,  'Reyes Agricultural Farm',   'Danao City, Cebu',   3.80, 3, 1),
  (4,  4,  'Garcia Vegetable Farm',     'Argao, Cebu',        1.75, 1, 3),
  (5,  5,  'Mendoza Farm',              'Bogo City, Cebu',    5.00, 4, 2),
  (6,  6,  'Flores Corn Farm',          'Toledo City, Cebu',  3.40, 3, 1),
  (7,  7,  'Cruz Family Farm',          'Naga City, Cebu',    2.80, 1, 2),
  (8,  8,  'Lim Agricultural Farm',     'Minglanilla, Cebu',  2.25, 2, 3),
  (9,  9,  'Fernandez Farm',            'Liloan, Cebu',       3.10, 3, 1),
  (10, 10, 'Villanueva Green Farm',     'Compostela, Cebu',   4.50, 1, 2),
  (11, 11, 'Navarro Rice Field',        'Talisay City, Cebu', 3.75, 4, 2),
  (12, 12, 'Ramos Farm',                'Consolacion, Cebu',  2.60, 1, 1),
  (13, 13, 'Torres Vegetable Farm',     'Dalaguete, Cebu',    1.80, 3, 3),
  (14, 14, 'Castillo Agricultural Farm','Barili, Cebu',       5.50, 2, 2),
  (15, 15, 'Aquino Farm',               'Sibonga, Cebu',      3.20, 1, 1);


-- ---------------------------------------------------------------------
-- PLANTING (50)  status: 1 Planted 2 Growing 3 Harvested 4 Failed
--   Same 50 rows as the original PHP installer (agriculture_db) and the
--   brief's screenshot (rows 11-28):
--   farm cycles 1-15, crop cycles 1-10, date +3 days per row,
--   area = 0.50 + (i % 10) * 0.10, seed = 10 + (i % 8) * 5,
--   expected_harvest_date = planting_date + crop growing_period_days,
--   rows 1-20 Harvested, rows 21-50 Growing.
-- ---------------------------------------------------------------------
insert into planting (planting_id, farm_id, crop_id, planting_date, area_planted, seed_quantity, expected_harvest_date, status_id) overriding system value values
  (1,1,1,'2026-01-10',0.50,10.00,'2026-05-05',3),
  (2,2,2,'2026-01-13',0.60,15.00,'2026-04-23',3),
  (3,3,3,'2026-01-16',0.70,20.00,'2026-04-16',3),
  (4,4,4,'2026-01-19',0.80,25.00,'2026-04-29',3),
  (5,5,5,'2026-01-22',0.90,30.00,'2026-11-18',3),
  (6,6,6,'2026-01-25',1.00,35.00,'2026-06-24',3),
  (7,7,7,'2026-01-28',1.10,40.00,'2026-05-18',3),
  (8,8,8,'2026-01-31',1.20,45.00,'2026-09-28',3),
  (9,9,9,'2026-02-03',1.30,10.00,'2026-06-03',3),
  (10,10,10,'2026-02-06',1.40,15.00,'2026-05-02',3),
  (11,11,1,'2026-02-09',0.50,20.00,'2026-06-04',3),
  (12,12,2,'2026-02-12',0.60,25.00,'2026-05-23',3),
  (13,13,3,'2026-02-15',0.70,30.00,'2026-05-16',3),
  (14,14,4,'2026-02-18',0.80,35.00,'2026-05-29',3),
  (15,15,5,'2026-02-21',0.90,40.00,'2026-12-18',3),
  (16,1,6,'2026-02-24',1.00,45.00,'2026-07-24',3),
  (17,2,7,'2026-02-27',1.10,10.00,'2026-06-17',3),
  (18,3,8,'2026-03-02',1.20,15.00,'2026-10-28',3),
  (19,4,9,'2026-03-05',1.30,20.00,'2026-07-03',3),
  (20,5,10,'2026-03-08',1.40,25.00,'2026-06-01',3),
  (21,6,1,'2026-03-11',0.50,30.00,'2026-07-04',2),
  (22,7,2,'2026-03-14',0.60,35.00,'2026-06-22',2),
  (23,8,3,'2026-03-17',0.70,40.00,'2026-06-15',2),
  (24,9,4,'2026-03-20',0.80,45.00,'2026-06-28',2),
  (25,10,5,'2026-03-23',0.90,10.00,'2027-01-17',2),
  (26,11,6,'2026-03-26',1.00,15.00,'2026-08-23',2),
  (27,12,7,'2026-03-29',1.10,20.00,'2026-07-17',2),
  (28,13,8,'2026-04-01',1.20,25.00,'2026-11-27',2),
  (29,14,9,'2026-04-04',1.30,30.00,'2026-08-02',2),
  (30,15,10,'2026-04-07',1.40,35.00,'2026-07-01',2),
  (31,1,1,'2026-04-10',0.50,40.00,'2026-08-03',2),
  (32,2,2,'2026-04-13',0.60,45.00,'2026-07-22',2),
  (33,3,3,'2026-04-16',0.70,10.00,'2026-07-15',2),
  (34,4,4,'2026-04-19',0.80,15.00,'2026-07-28',2),
  (35,5,5,'2026-04-22',0.90,20.00,'2027-02-16',2),
  (36,6,6,'2026-04-25',1.00,25.00,'2026-09-22',2),
  (37,7,7,'2026-04-28',1.10,30.00,'2026-08-16',2),
  (38,8,8,'2026-05-01',1.20,35.00,'2026-12-27',2),
  (39,9,9,'2026-05-04',1.30,40.00,'2026-09-01',2),
  (40,10,10,'2026-05-07',1.40,45.00,'2026-07-31',2),
  (41,11,1,'2026-05-10',0.50,10.00,'2026-09-02',2),
  (42,12,2,'2026-05-13',0.60,15.00,'2026-08-21',2),
  (43,13,3,'2026-05-16',0.70,20.00,'2026-08-14',2),
  (44,14,4,'2026-05-19',0.80,25.00,'2026-08-27',2),
  (45,15,5,'2026-05-22',0.90,30.00,'2027-03-18',2),
  (46,1,6,'2026-05-25',1.00,35.00,'2026-10-22',2),
  (47,2,7,'2026-05-28',1.10,40.00,'2026-09-15',2),
  (48,3,8,'2026-05-31',1.20,45.00,'2027-01-26',2),
  (49,4,9,'2026-06-03',1.30,10.00,'2026-10-01',2),
  (50,5,10,'2026-06-06',1.40,15.00,'2026-08-30',2);


-- ---------------------------------------------------------------------
-- HARVEST (20)  grade: 1 A 2 B 3 C
--   Same values as the PHP installer: price = 22 + (i % 8) * 3.50,
--   harvest_date = expected_harvest_date + 2 days, grade by i % 3.
--   remark mapping from the old free text to the required lookup:
--     "High quality harvest" -> 1 Good Harvest
--     "Good harvest"         -> 1 Good Harvest
--     "Acceptable quality"   -> 2 Acceptable Quality
-- ---------------------------------------------------------------------
insert into harvest (harvest_id, planting_id, harvest_date, quantity_kg, selling_price_per_kg, grade_id, remark_id) overriding system value values
  (1,  1,  '2026-05-07',  900.00, 22.00, 1, 1),
  (2,  2,  '2026-04-25', 1025.00, 25.50, 2, 1),
  (3,  3,  '2026-04-18', 1150.00, 29.00, 3, 2),
  (4,  4,  '2026-05-01', 1275.00, 32.50, 1, 1),
  (5,  5,  '2026-11-20', 1400.00, 36.00, 2, 1),
  (6,  6,  '2026-06-26', 1525.00, 39.50, 3, 2),
  (7,  7,  '2026-05-20', 1650.00, 43.00, 1, 1),
  (8,  8,  '2026-09-30', 1775.00, 46.50, 2, 1),
  (9,  9,  '2026-06-05', 1900.00, 22.00, 3, 2),
  (10, 10, '2026-05-04', 2025.00, 25.50, 1, 1),
  (11, 11, '2026-06-06', 2150.00, 29.00, 2, 1),
  (12, 12, '2026-05-25', 2275.00, 32.50, 3, 2),
  (13, 13, '2026-05-18', 2400.00, 36.00, 1, 1),
  (14, 14, '2026-05-31', 2525.00, 39.50, 2, 1),
  (15, 15, '2026-12-20', 2650.00, 43.00, 3, 2),
  (16, 16, '2026-07-26', 2775.00, 46.50, 1, 1),
  (17, 17, '2026-06-19', 2900.00, 22.00, 2, 1),
  (18, 18, '2026-10-30', 3025.00, 25.50, 3, 2),
  (19, 19, '2026-07-05', 3150.00, 29.00, 1, 1),
  (20, 20, '2026-06-03', 3275.00, 32.50, 2, 1);


-- ---------------------------------------------------------------------
-- BUYER (10)  type: 1 Wholesaler 2 Retailer 3 Cooperative 4 Food Processor 5 Market Vendor
--   Fictional businesses for demonstration.
-- ---------------------------------------------------------------------
insert into buyer (buyer_id, buyer_name, buyer_type_id, contact_person, contact_number, address) overriding system value values
  (1,  'Carbon Market Produce Traders',   1, 'Lito Abella',     '09321110001', 'Carbon Market, Cebu City'),
  (2,  'Mandaue Fresh Grocers',           2, 'Grace Tan',       '09321110002', 'Mandaue City, Cebu'),
  (3,  'Cebu South Farmers Cooperative',  3, 'Nestor Ybanez',   '09321110003', 'Carcar City, Cebu'),
  (4,  'Talisay Fruit Processing Co.',    4, 'Merlinda Go',     '09321110004', 'Talisay City, Cebu'),
  (5,  'Pasil Wet Market Stall 14',       5, 'Bebot Alcoseba',  '09321110005', 'Pasil, Cebu City'),
  (6,  'Danao North Grains Wholesale',    1, 'Ricardo Sy',      '09321110006', 'Danao City, Cebu'),
  (7,  'Lapu-Lapu Resort Supply',         2, 'Joy Pacquiao',    '09321110007', 'Lapu-Lapu City, Cebu'),
  (8,  'Argao Highland Cooperative',      3, 'Dante Villamor',  '09321110008', 'Argao, Cebu'),
  (9,  'Visayan Snack Foods Inc.',        4, 'Helen Chiong',    '09321110009', 'Mandaue City, Cebu'),
  (10, 'Toledo Public Market Vendor',     5, 'Nena Labra',      '09321110010', 'Toledo City, Cebu');


-- ---------------------------------------------------------------------
-- SALE (27)  - never earlier than the harvest, never more than harvested
-- ---------------------------------------------------------------------
insert into sale (sale_id, harvest_id, buyer_id, sale_date, quantity_kg, price_per_kg) overriding system value values
  (1,1,1,'2026-05-10',540.00,22.00),
  (2,2,2,'2026-04-28',615.00,25.50),
  (3,2,3,'2026-05-16',255.00,26.50),
  (4,3,4,'2026-04-21',690.00,29.00),
  (5,4,5,'2026-05-04',765.00,32.50),
  (6,4,6,'2026-05-22',320.00,33.50),
  (7,6,7,'2026-06-29',915.00,39.50),
  (8,6,8,'2026-07-17',380.00,40.50),
  (9,7,9,'2026-05-23',990.00,43.00),
  (10,8,10,'2026-10-03',1065.00,46.50),
  (11,8,1,'2026-10-21',445.00,47.50),
  (12,9,2,'2026-06-08',1140.00,22.00),
  (13,10,3,'2026-05-07',1215.00,25.50),
  (14,10,4,'2026-05-25',505.00,26.50),
  (15,11,5,'2026-06-09',1290.00,29.00),
  (16,12,6,'2026-05-28',1365.00,32.50),
  (17,12,7,'2026-06-15',570.00,33.50),
  (18,13,8,'2026-05-21',1440.00,36.00),
  (19,14,9,'2026-06-03',1515.00,39.50),
  (20,14,10,'2026-06-21',630.00,40.50),
  (21,16,1,'2026-07-29',1665.00,46.50),
  (22,16,2,'2026-08-16',695.00,47.50),
  (23,17,3,'2026-06-22',1740.00,22.00),
  (24,18,4,'2026-10-31',1815.00,25.50),
  (25,19,5,'2026-07-08',1890.00,29.00),
  (26,20,6,'2026-06-06',1965.00,32.50),
  (27,20,7,'2026-06-24',820.00,33.50);


-- ---------------------------------------------------------------------
-- INPUT_ITEM (10)  type: 1 Inorganic Fert. 2 Organic Fert. 3 Insecticide 4 Fungicide 5 Herbicide
--                  unit: 1 kg 2 L 3 sack
-- ---------------------------------------------------------------------
insert into input_item (input_id, input_name, input_type_id, unit_id, unit_cost) overriding system value values
  (1,  'Urea (46-0-0)',                1, 1,  32.00),
  (2,  'Complete Fertilizer (14-14-14)', 1, 1, 36.00),
  (3,  'Ammonium Sulfate (21-0-0)',    1, 1,  20.00),
  (4,  'Muriate of Potash (0-0-60)',   1, 1,  38.00),
  (5,  'Vermicompost',                 2, 1,  12.00),
  (6,  'Chicken Manure Compost',       2, 3, 250.00),
  (7,  'Cypermethrin 5% EC',           3, 2, 650.00),
  (8,  'Lambda-cyhalothrin 2.5% EC',   3, 2, 900.00),
  (9,  'Mancozeb 80% WP',              4, 1, 480.00),
  (10, 'Glyphosate 41% SL',            5, 2, 420.00);


-- ---------------------------------------------------------------------
-- INPUT_USAGE (59)  - never earlier than the planting date
-- ---------------------------------------------------------------------
insert into input_usage (usage_id, planting_id, input_id, usage_date, quantity) overriding system value values
  (1,1,1,'2026-01-17',50.00), (2,1,7,'2026-02-14',0.75), (3,1,3,'2026-02-09',25.00),
  (4,2,1,'2026-01-20',60.00), (5,2,3,'2026-02-12',30.00),
  (6,3,2,'2026-01-23',70.00), (7,3,9,'2026-02-20',1.05), (8,3,5,'2026-01-16',280.00),
  (9,4,2,'2026-01-26',80.00),
  (10,5,2,'2026-01-29',90.00), (11,5,7,'2026-02-26',1.35),
  (12,6,2,'2026-02-01',100.00), (13,6,5,'2026-01-25',400.00),
  (14,7,2,'2026-02-04',110.00), (15,7,9,'2026-03-04',1.65),
  (16,8,2,'2026-02-07',120.00),
  (17,9,2,'2026-02-10',130.00), (18,9,7,'2026-03-10',1.95), (19,9,5,'2026-02-03',520.00),
  (20,10,2,'2026-02-13',140.00),
  (21,11,1,'2026-02-16',50.00), (22,11,9,'2026-03-16',0.75), (23,11,3,'2026-03-11',25.00),
  (24,12,1,'2026-02-19',60.00), (25,12,5,'2026-02-12',240.00), (26,12,3,'2026-03-14',30.00),
  (27,13,2,'2026-02-22',70.00), (28,13,7,'2026-03-22',1.05),
  (29,14,2,'2026-02-25',80.00),
  (30,15,2,'2026-02-28',90.00), (31,15,9,'2026-03-28',1.35), (32,15,5,'2026-02-21',360.00),
  (33,16,2,'2026-03-03',100.00),
  (34,17,2,'2026-03-06',110.00), (35,17,7,'2026-04-03',1.65),
  (36,18,2,'2026-03-09',120.00), (37,18,5,'2026-03-02',480.00),
  (38,19,2,'2026-03-12',130.00), (39,19,9,'2026-04-09',1.95),
  (40,20,2,'2026-03-15',140.00),
  (41,21,1,'2026-03-18',50.00), (42,21,7,'2026-04-15',0.75), (43,21,5,'2026-03-11',200.00),
  (44,22,1,'2026-03-21',60.00),
  (45,23,2,'2026-03-24',70.00), (46,23,9,'2026-04-21',1.05),
  (47,24,2,'2026-03-27',80.00), (48,24,5,'2026-03-20',320.00),
  (49,25,2,'2026-03-30',90.00), (50,25,7,'2026-04-27',1.35),
  (51,26,2,'2026-04-02',100.00),
  (52,27,2,'2026-04-05',110.00), (53,27,9,'2026-05-03',1.65), (54,27,5,'2026-03-29',440.00),
  (55,28,2,'2026-04-08',120.00),
  (56,29,2,'2026-04-11',130.00), (57,29,7,'2026-05-09',1.95),
  (58,30,2,'2026-04-14',140.00), (59,30,5,'2026-04-07',560.00);


-- ---------------------------------------------------------------------
-- Move every IDENTITY counter past the IDs used above, so new records
-- created from the app get the next free number.
-- ---------------------------------------------------------------------
do $$
declare
  t record;
begin
  for t in
    select * from (values
      ('app_role','role_id'), ('crop_category','category_id'), ('season','season_id'),
      ('soil_type','soil_type_id'), ('irrigation_type','irrigation_type_id'),
      ('planting_status','status_id'), ('quality_grade','grade_id'),
      ('harvest_remark','remark_id'), ('buyer_type','buyer_type_id'),
      ('input_type','input_type_id'), ('unit_of_measure','unit_id'),
      ('farmer','farmer_id'), ('farm','farm_id'), ('crop','crop_id'),
      ('planting','planting_id'), ('harvest','harvest_id'), ('buyer','buyer_id'),
      ('sale','sale_id'), ('input_item','input_id'), ('input_usage','usage_id')
    ) as x(tbl, col)
  loop
    execute format('select setval(pg_get_serial_sequence(%L, %L), (select max(%I) from %I))',
                   t.tbl, t.col, t.col, t.tbl);
  end loop;
end $$;

-- The seed inserts are not real user actions; start the audit log clean.
delete from audit_log;

commit;

-- After you create users in Authentication > Users, assign roles:
--   update profile set role_id = 1 where email = 'admin@example.com';   -- Administrator
--   update profile set role_id = 2 where email = 'staff@example.com';   -- Staff
--   (new users default to role 3 = Viewer)
