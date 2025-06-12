/*
 Navicat Premium Data Transfer

 Source Server         : localhost_5432
 Source Server Type    : PostgreSQL
 Source Server Version : 130020 (130020)
 Source Host           : localhost:5432
 Source Catalog        : postgres
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 130020 (130020)
 File Encoding         : 65001

 Date: 09/06/2025 18:55:47
*/


-- ----------------------------
-- Table structure for web_shop
-- ----------------------------
DROP TABLE IF EXISTS "public"."web_shop";
CREATE TABLE "public"."web_shop" (
  "id_web_shop" int4 NOT NULL DEFAULT nextval('web_shop_sequence'::regclass),
  "id_web_shop_category" int4,
  "item_id" int4,
  "sku_web_shop" varchar(255) COLLATE "pg_catalog"."default",
  "thumbnail_web_shop" varchar(255) COLLATE "pg_catalog"."default",
  "description_web_shop" text COLLATE "pg_catalog"."default",
  "normal_price_web_shop" int4,
  "discount_price_web_shop" int4,
  "stock_web_shop" int4,
  "count_web_shop" varchar(32) COLLATE "pg_catalog"."default",
  "is_discount_web_shop" int4,
  "total_bought_web_shop" int4,
  "total_views_web_shop" int4,
  "status_web_shop" int4,
  "created_at" timestamp(0),
  "updated_at" timestamp(0)
)
;

-- ----------------------------
-- Records of web_shop
-- ----------------------------
INSERT INTO "public"."web_shop" VALUES (23, 2, 106152, 'M1887 Arcade', '8b6991859d5988516379b896d23409ac.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 997, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-20 04:12:31');
INSERT INTO "public"."web_shop" VALUES (16, 1, 106161, 'M1887 Viper', '2817b9eb58f133d3975adbbf38d9f7d4.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 998, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-22 23:39:46');
INSERT INTO "public"."web_shop" VALUES (18, 2, 103470, 'AUG A3 Arcade', '172d7bccb1e092570f2e16e13efe78e5.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 972, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 05:48:39');
INSERT INTO "public"."web_shop" VALUES (22, 2, 105321, 'Tactilite T2 Arcade', 'c52477a64a588c29498bc9c213f99d27.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 995, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 05:48:46');
INSERT INTO "public"."web_shop" VALUES (24, 2, 214028, 'Scorpion Vz61 Arcade', '8a8cedcd73fa6a8c6eeea45226e9e8ac.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 973, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-29 21:50:59');
INSERT INTO "public"."web_shop" VALUES (12, 1, 103490, 'SC-2010 Viper', '8ddda77bdfe87fa6942a937f15dacc7e.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 954, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-04-01 02:35:17');
INSERT INTO "public"."web_shop" VALUES (7, 3, 103131, 'AUG A3 LATIN3', '675ad1915927546ee3302bc5cf36029d.png', 'AUG A3 es un arma fabricada en SteyrMannlicher en Austria, tiene alta precisión y velocidad de disparo porque utiliza un receptor con riel MIL-STD-1913.', 200, 0, 890, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-04-01 03:49:59');
INSERT INTO "public"."web_shop" VALUES (11, 1, 103489, 'AUG A3 VIPER', 'b0a64b521045739f9eba302d8327a45f.png', '¡Viper es morado y negro, como una serpiente venenosa! ¡Ten cuidado al usarlo!', 200, 0, 970, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-29 21:52:08');
INSERT INTO "public"."web_shop" VALUES (25, 2, 301243, 'Combat Machete Arcade', '1479ba886a70746b81d81ea48dc91b2d.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 982, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 05:48:59');
INSERT INTO "public"."web_shop" VALUES (15, 1, 105341, 'Tactilite T2 Viper', '424b243bc7e278a75fb64d61e7806bd4.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 993, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 05:49:39');
INSERT INTO "public"."web_shop" VALUES (17, 1, 301255, 'Karambit Viper', '380f8c1f20afa3f4452269bd4db5e8dc.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 970, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 12:04:11');
INSERT INTO "public"."web_shop" VALUES (19, 2, 104639, 'Kriss S.V Arcade', '59337684e4e5ab96625faf0318f318b6.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 985, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 12:05:39');
INSERT INTO "public"."web_shop" VALUES (14, 1, 104686, 'OA-93 Viper', '167ecfbe777d6f2f23edfdcab932920e.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 982, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-30 04:28:54');
INSERT INTO "public"."web_shop" VALUES (21, 2, 105320, 'Cheytac M200 Arcade', 'a2eee61ff7a7a30c98a95f3265e02c1a.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 997, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 05:48:24');
INSERT INTO "public"."web_shop" VALUES (20, 2, 104641, 'OA-93 Arcade', 'a5e156a64b160f478ecaf0cb5392691d.png', 'Arcade está inspirado en juegos retro, con características únicas de colores neón brillantes y logotipos típicos de juegos retro.', 200, 0, 983, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-03-31 12:05:46');
INSERT INTO "public"."web_shop" VALUES (13, 1, 104684, 'Kriss S.V Viper', 'c8f14ccfc37b1c04e92bbd0864b307eb.png', 'sa! ¡Ten cuidado al usarlo!', 200, 0, 963, '2', 0, 0, 0, 1, '2025-03-19 11:57:01', '2025-04-01 00:29:45');

-- ----------------------------
-- Table structure for web_shop_category
-- ----------------------------
DROP TABLE IF EXISTS "public"."web_shop_category";
CREATE TABLE "public"."web_shop_category" (
  "id_web_shop_category" int4 NOT NULL DEFAULT nextval('web_shop_category_sequence'::regclass),
  "name_web_shop_category" varchar(255) COLLATE "pg_catalog"."default",
  "slug_web_shop_category" varchar(255) COLLATE "pg_catalog"."default",
  "status_web_shop_category" int4,
  "created_at" timestamp(0),
  "updated_at" timestamp(0)
)
;

-- ----------------------------
-- Records of web_shop_category
-- ----------------------------
INSERT INTO "public"."web_shop_category" VALUES (1, 'Trending Now', 'trending-now', 1, '2025-01-17 12:25:43', NULL);
INSERT INTO "public"."web_shop_category" VALUES (2, 'New', 'new', 1, '2025-01-17 12:25:55', NULL);
INSERT INTO "public"."web_shop_category" VALUES (3, 'Sale', 'sale', 1, '2025-01-17 12:26:01', NULL);
INSERT INTO "public"."web_shop_category" VALUES (4, 'Star Rating', 'star-rating', 1, '2025-01-17 12:26:18', '2025-01-17 12:26:58');

-- ----------------------------
-- Primary Key structure for table web_shop
-- ----------------------------
ALTER TABLE "public"."web_shop" ADD CONSTRAINT "webshop_pkey" PRIMARY KEY ("id_web_shop");

-- ----------------------------
-- Primary Key structure for table web_shop_category
-- ----------------------------
ALTER TABLE "public"."web_shop_category" ADD CONSTRAINT "web_shop_category_pkey" PRIMARY KEY ("id_web_shop_category");
