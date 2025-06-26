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

 Date: 08/06/2025 16:34:02
*/


-- ----------------------------
-- Table structure for launcher_ban
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_ban";
CREATE TABLE "public"."launcher_ban" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_ban_hwid_id_seq'::regclass),
  "hwid" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "serial_number" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "reason" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "mac_address" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "is_banned" bool NOT NULL DEFAULT false,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON TABLE "public"."launcher_ban" IS 'HWIDs baneados del launcher';

-- ----------------------------
-- Records of launcher_ban
-- ----------------------------
INSERT INTO "public"."launcher_ban" VALUES (1, '0AE8DE75850D92FF5F877522F16FBA538E71AFB653E049E35A34144B72FD7D05', '2L082LANS6JT', 'Desbaneado por administrador', '0250EC5321A4', 'f', '2025-05-28 20:09:55.456767');
INSERT INTO "public"."launcher_ban" VALUES (2, '0AE8DE75850D92FF5F877522F16FBA538E71AFB653E049E35A34144B72FD7D05', '2L082LANS6JT        ', 'Automatically registered', '0250EC5321A4', 'f', '2025-06-04 22:55:12.958222');

-- ----------------------------
-- Table structure for launcher_banner_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_banner_config";
CREATE TABLE "public"."launcher_banner_config" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_banner_config_id_seq'::regclass),
  "name" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "description" text COLLATE "pg_catalog"."default",
  "is_active" bool DEFAULT false,
  "is_default" bool DEFAULT false,
  "auto_rotate" bool DEFAULT true,
  "rotation_interval" int4 DEFAULT 6000,
  "responsive" bool DEFAULT true,
  "show_controller" bool DEFAULT true,
  "width" int4 DEFAULT 775,
  "height" int4 DEFAULT 394,
  "enable_socketio" bool DEFAULT true,
  "enable_real_time" bool DEFAULT true,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int4
)
;

-- ----------------------------
-- Records of launcher_banner_config
-- ----------------------------
INSERT INTO "public"."launcher_banner_config" VALUES (1, 'Banner Principal', 'Banner principal del launcher con información en tiempo real', 't', 't', 't', 6000, 't', 't', 1016, 540, 't', 't', '2025-06-07 20:04:32.575674', '2025-06-08 01:37:41.524239', NULL);

-- ----------------------------
-- Table structure for launcher_banner_slide
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_banner_slide";
CREATE TABLE "public"."launcher_banner_slide" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_banner_slide_id_seq'::regclass),
  "banner_id" int4 NOT NULL,
  "title" varchar(255) COLLATE "pg_catalog"."default",
  "content" text COLLATE "pg_catalog"."default",
  "image_url" varchar(500) COLLATE "pg_catalog"."default",
  "link_url" varchar(500) COLLATE "pg_catalog"."default",
  "order_index" int4 DEFAULT 0,
  "is_active" bool DEFAULT true,
  "duration" int4 DEFAULT 6000,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;

-- ----------------------------
-- Records of launcher_banner_slide
-- ----------------------------
INSERT INTO "public"."launcher_banner_slide" VALUES (1, 1, 'Bienvenido al Launcher', 'Sistema de launcher con información en tiempo real', 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg', 'https://www.pb-lite.com/', 0, 't', 6000, '2025-06-07 20:04:32.576873', '2025-06-07 20:04:32.576873');
INSERT INTO "public"."launcher_banner_slide" VALUES (4, 1, 'test titulo', 'sadasda', 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg', '', 1, 't', 6000, '2025-06-08 01:46:16.175567', '2025-06-08 01:46:16.175571');

-- ----------------------------
-- Table structure for launcher_download_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_download_log";
CREATE TABLE "public"."launcher_download_log" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_download_log_id_seq'::regclass),
  "ip_address" inet NOT NULL,
  "user_agent" varchar(500) COLLATE "pg_catalog"."default",
  "file_requested" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "file_type" varchar(50) COLLATE "pg_catalog"."default",
  "success" bool DEFAULT false,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON TABLE "public"."launcher_download_log" IS 'Log de descargas de archivos';

-- ----------------------------
-- Records of launcher_download_log
-- ----------------------------
INSERT INTO "public"."launcher_download_log" VALUES (1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-28 20:16:31.028748');
INSERT INTO "public"."launcher_download_log" VALUES (2, '127.0.0.1', 'GameLauncher/1.0', 'update.json', 'update_check', 't', '2025-05-28 20:17:22.394018');
INSERT INTO "public"."launcher_download_log" VALUES (3, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-28 20:20:15.482372');
INSERT INTO "public"."launcher_download_log" VALUES (4, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-05-28 20:20:21.332369');
INSERT INTO "public"."launcher_download_log" VALUES (5, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-28 20:21:33.513599');
INSERT INTO "public"."launcher_download_log" VALUES (6, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-05-28 20:21:34.432414');
INSERT INTO "public"."launcher_download_log" VALUES (7, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-28 20:24:04.050196');
INSERT INTO "public"."launcher_download_log" VALUES (8, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-05-28 20:24:20.777958');
INSERT INTO "public"."launcher_download_log" VALUES (9, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-05-28 20:24:20.814641');
INSERT INTO "public"."launcher_download_log" VALUES (10, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-28 20:24:21.138359');
INSERT INTO "public"."launcher_download_log" VALUES (11, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-05-28 20:31:57.244654');
INSERT INTO "public"."launcher_download_log" VALUES (12, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-05-28 20:31:57.326186');
INSERT INTO "public"."launcher_download_log" VALUES (13, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-28 20:31:57.591091');
INSERT INTO "public"."launcher_download_log" VALUES (14, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-29 01:27:58.864266');
INSERT INTO "public"."launcher_download_log" VALUES (15, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-05-29 01:35:16.284217');
INSERT INTO "public"."launcher_download_log" VALUES (16, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-05-29 01:35:16.391231');
INSERT INTO "public"."launcher_download_log" VALUES (17, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'banner.html', 'banner', 't', '2025-05-29 01:35:16.714476');
INSERT INTO "public"."launcher_download_log" VALUES (18, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 19:19:02.659904');
INSERT INTO "public"."launcher_download_log" VALUES (19, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 19:22:46.121025');
INSERT INTO "public"."launcher_download_log" VALUES (20, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 19:44:30.26545');
INSERT INTO "public"."launcher_download_log" VALUES (21, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 20:35:53.701837');
INSERT INTO "public"."launcher_download_log" VALUES (22, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 20:38:15.670567');
INSERT INTO "public"."launcher_download_log" VALUES (23, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 20:43:27.269987');
INSERT INTO "public"."launcher_download_log" VALUES (24, '192.168.18.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'launcher_update', 'launcher_check', 't', '2025-05-30 21:08:29.198822');
INSERT INTO "public"."launcher_download_log" VALUES (25, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 18:49:29.727473');
INSERT INTO "public"."launcher_download_log" VALUES (26, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:39:41.111426');
INSERT INTO "public"."launcher_download_log" VALUES (27, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:39:41.170621');
INSERT INTO "public"."launcher_download_log" VALUES (28, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:39:47.214742');
INSERT INTO "public"."launcher_download_log" VALUES (29, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:40:47.625504');
INSERT INTO "public"."launcher_download_log" VALUES (30, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:41:47.640137');
INSERT INTO "public"."launcher_download_log" VALUES (31, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:42:47.631867');
INSERT INTO "public"."launcher_download_log" VALUES (32, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:43:28.527689');
INSERT INTO "public"."launcher_download_log" VALUES (33, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:43:28.623155');
INSERT INTO "public"."launcher_download_log" VALUES (34, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:29.164055');
INSERT INTO "public"."launcher_download_log" VALUES (35, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:30.4972');
INSERT INTO "public"."launcher_download_log" VALUES (36, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:31.501473');
INSERT INTO "public"."launcher_download_log" VALUES (37, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:32.499973');
INSERT INTO "public"."launcher_download_log" VALUES (38, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:33.496289');
INSERT INTO "public"."launcher_download_log" VALUES (39, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:34.494522');
INSERT INTO "public"."launcher_download_log" VALUES (40, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:35.501663');
INSERT INTO "public"."launcher_download_log" VALUES (41, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:36.505988');
INSERT INTO "public"."launcher_download_log" VALUES (42, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:37.500776');
INSERT INTO "public"."launcher_download_log" VALUES (43, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:38.498951');
INSERT INTO "public"."launcher_download_log" VALUES (44, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:39.498157');
INSERT INTO "public"."launcher_download_log" VALUES (45, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:40.50007');
INSERT INTO "public"."launcher_download_log" VALUES (46, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:41.491824');
INSERT INTO "public"."launcher_download_log" VALUES (47, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:42.495475');
INSERT INTO "public"."launcher_download_log" VALUES (48, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:43.49834');
INSERT INTO "public"."launcher_download_log" VALUES (49, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:44.502107');
INSERT INTO "public"."launcher_download_log" VALUES (50, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:45.500207');
INSERT INTO "public"."launcher_download_log" VALUES (51, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:46.502214');
INSERT INTO "public"."launcher_download_log" VALUES (52, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:47.495325');
INSERT INTO "public"."launcher_download_log" VALUES (53, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:48.512341');
INSERT INTO "public"."launcher_download_log" VALUES (56, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:51.499996');
INSERT INTO "public"."launcher_download_log" VALUES (57, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:52.503479');
INSERT INTO "public"."launcher_download_log" VALUES (60, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:55.496436');
INSERT INTO "public"."launcher_download_log" VALUES (61, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:56.497034');
INSERT INTO "public"."launcher_download_log" VALUES (64, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:59.505716');
INSERT INTO "public"."launcher_download_log" VALUES (65, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:00.50975');
INSERT INTO "public"."launcher_download_log" VALUES (68, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:03.497447');
INSERT INTO "public"."launcher_download_log" VALUES (69, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:04.50926');
INSERT INTO "public"."launcher_download_log" VALUES (72, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:07.492749');
INSERT INTO "public"."launcher_download_log" VALUES (73, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:44:14.12865');
INSERT INTO "public"."launcher_download_log" VALUES (75, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:14.753597');
INSERT INTO "public"."launcher_download_log" VALUES (77, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:16.781401');
INSERT INTO "public"."launcher_download_log" VALUES (79, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:18.781103');
INSERT INTO "public"."launcher_download_log" VALUES (81, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:20.782457');
INSERT INTO "public"."launcher_download_log" VALUES (83, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:22.782376');
INSERT INTO "public"."launcher_download_log" VALUES (86, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:26.097278');
INSERT INTO "public"."launcher_download_log" VALUES (88, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:28.090559');
INSERT INTO "public"."launcher_download_log" VALUES (91, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:44:38.244088');
INSERT INTO "public"."launcher_download_log" VALUES (1255, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:26.583562');
INSERT INTO "public"."launcher_download_log" VALUES (1256, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:26.600322');
INSERT INTO "public"."launcher_download_log" VALUES (1259, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:28.628845');
INSERT INTO "public"."launcher_download_log" VALUES (1261, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:56.601319');
INSERT INTO "public"."launcher_download_log" VALUES (1262, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:56.616345');
INSERT INTO "public"."launcher_download_log" VALUES (1263, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:56.626849');
INSERT INTO "public"."launcher_download_log" VALUES (1264, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:56.638519');
INSERT INTO "public"."launcher_download_log" VALUES (1266, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:58.652531');
INSERT INTO "public"."launcher_download_log" VALUES (1269, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:28.650012');
INSERT INTO "public"."launcher_download_log" VALUES (1271, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:30.652886');
INSERT INTO "public"."launcher_download_log" VALUES (1274, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:56.637419');
INSERT INTO "public"."launcher_download_log" VALUES (1277, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:58.645072');
INSERT INTO "public"."launcher_download_log" VALUES (1502, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:44.694337');
INSERT INTO "public"."launcher_download_log" VALUES (1503, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:51.031377');
INSERT INTO "public"."launcher_download_log" VALUES (1504, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:51.068764');
INSERT INTO "public"."launcher_download_log" VALUES (1507, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:53.118478');
INSERT INTO "public"."launcher_download_log" VALUES (1509, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:18:34.734648');
INSERT INTO "public"."launcher_download_log" VALUES (1511, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:18:34.978868');
INSERT INTO "public"."launcher_download_log" VALUES (1512, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:18:35.01255');
INSERT INTO "public"."launcher_download_log" VALUES (1517, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:09.342341');
INSERT INTO "public"."launcher_download_log" VALUES (1521, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:39.325083');
INSERT INTO "public"."launcher_download_log" VALUES (1528, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:20:09.335633');
INSERT INTO "public"."launcher_download_log" VALUES (1530, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:20:09.37226');
INSERT INTO "public"."launcher_download_log" VALUES (1535, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:12.429884');
INSERT INTO "public"."launcher_download_log" VALUES (1536, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:12.478546');
INSERT INTO "public"."launcher_download_log" VALUES (1539, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:47.145876');
INSERT INTO "public"."launcher_download_log" VALUES (1540, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:47.176037');
INSERT INTO "public"."launcher_download_log" VALUES (1545, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:17.268481');
INSERT INTO "public"."launcher_download_log" VALUES (1546, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:17.300134');
INSERT INTO "public"."launcher_download_log" VALUES (1559, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:17.544915');
INSERT INTO "public"."launcher_download_log" VALUES (1560, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:17.574497');
INSERT INTO "public"."launcher_download_log" VALUES (1561, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:19.934701');
INSERT INTO "public"."launcher_download_log" VALUES (1562, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:19.964912');
INSERT INTO "public"."launcher_download_log" VALUES (1829, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:02.83551');
INSERT INTO "public"."launcher_download_log" VALUES (1831, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:02.983967');
INSERT INTO "public"."launcher_download_log" VALUES (1834, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:03.094585');
INSERT INTO "public"."launcher_download_log" VALUES (1835, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:37.405572');
INSERT INTO "public"."launcher_download_log" VALUES (1836, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:37.442126');
INSERT INTO "public"."launcher_download_log" VALUES (1838, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:37.473478');
INSERT INTO "public"."launcher_download_log" VALUES (1840, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:39.50752');
INSERT INTO "public"."launcher_download_log" VALUES (1843, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:07.358004');
INSERT INTO "public"."launcher_download_log" VALUES (1844, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:07.377681');
INSERT INTO "public"."launcher_download_log" VALUES (1846, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:09.383535');
INSERT INTO "public"."launcher_download_log" VALUES (1851, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:39.454016');
INSERT INTO "public"."launcher_download_log" VALUES (1854, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:09.389938');
INSERT INTO "public"."launcher_download_log" VALUES (1857, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:11.394154');
INSERT INTO "public"."launcher_download_log" VALUES (1859, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:37.379068');
INSERT INTO "public"."launcher_download_log" VALUES (1860, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:37.394358');
INSERT INTO "public"."launcher_download_log" VALUES (1861, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:37.411963');
INSERT INTO "public"."launcher_download_log" VALUES (1862, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:37.424');
INSERT INTO "public"."launcher_download_log" VALUES (1863, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:39.436338');
INSERT INTO "public"."launcher_download_log" VALUES (1865, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:13.844549');
INSERT INTO "public"."launcher_download_log" VALUES (1868, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:14.134139');
INSERT INTO "public"."launcher_download_log" VALUES (1870, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:14.206');
INSERT INTO "public"."launcher_download_log" VALUES (1872, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:48.499695');
INSERT INTO "public"."launcher_download_log" VALUES (2046, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:07.381297');
INSERT INTO "public"."launcher_download_log" VALUES (2048, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:07.938833');
INSERT INTO "public"."launcher_download_log" VALUES (2050, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:08.322134');
INSERT INTO "public"."launcher_download_log" VALUES (2052, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:42.845978');
INSERT INTO "public"."launcher_download_log" VALUES (54, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:49.507221');
INSERT INTO "public"."launcher_download_log" VALUES (55, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:50.503441');
INSERT INTO "public"."launcher_download_log" VALUES (58, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:53.496864');
INSERT INTO "public"."launcher_download_log" VALUES (59, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:54.499148');
INSERT INTO "public"."launcher_download_log" VALUES (62, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:57.494508');
INSERT INTO "public"."launcher_download_log" VALUES (63, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:43:58.496054');
INSERT INTO "public"."launcher_download_log" VALUES (66, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:01.502966');
INSERT INTO "public"."launcher_download_log" VALUES (67, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:02.501238');
INSERT INTO "public"."launcher_download_log" VALUES (70, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:05.500093');
INSERT INTO "public"."launcher_download_log" VALUES (71, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:06.500304');
INSERT INTO "public"."launcher_download_log" VALUES (74, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:44:14.227186');
INSERT INTO "public"."launcher_download_log" VALUES (76, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:16.092121');
INSERT INTO "public"."launcher_download_log" VALUES (78, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:18.090371');
INSERT INTO "public"."launcher_download_log" VALUES (80, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:20.08929');
INSERT INTO "public"."launcher_download_log" VALUES (82, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:22.093822');
INSERT INTO "public"."launcher_download_log" VALUES (84, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:24.094297');
INSERT INTO "public"."launcher_download_log" VALUES (85, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:25.083939');
INSERT INTO "public"."launcher_download_log" VALUES (87, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:26.782521');
INSERT INTO "public"."launcher_download_log" VALUES (89, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:28.782883');
INSERT INTO "public"."launcher_download_log" VALUES (90, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:44:38.086084');
INSERT INTO "public"."launcher_download_log" VALUES (92, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:38.714324');
INSERT INTO "public"."launcher_download_log" VALUES (93, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:49.060295');
INSERT INTO "public"."launcher_download_log" VALUES (94, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:44:59.05757');
INSERT INTO "public"."launcher_download_log" VALUES (95, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:46:23.688293');
INSERT INTO "public"."launcher_download_log" VALUES (96, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:46:23.776279');
INSERT INTO "public"."launcher_download_log" VALUES (97, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:46:24.314963');
INSERT INTO "public"."launcher_download_log" VALUES (98, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:46:52.546526');
INSERT INTO "public"."launcher_download_log" VALUES (99, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:46:52.638318');
INSERT INTO "public"."launcher_download_log" VALUES (100, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:46:53.170143');
INSERT INTO "public"."launcher_download_log" VALUES (101, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:47:03.518064');
INSERT INTO "public"."launcher_download_log" VALUES (102, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:47:13.512983');
INSERT INTO "public"."launcher_download_log" VALUES (103, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:47:30.843519');
INSERT INTO "public"."launcher_download_log" VALUES (104, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:47:30.951039');
INSERT INTO "public"."launcher_download_log" VALUES (105, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:47:31.64071');
INSERT INTO "public"."launcher_download_log" VALUES (106, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:47:41.970455');
INSERT INTO "public"."launcher_download_log" VALUES (107, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:47:51.97127');
INSERT INTO "public"."launcher_download_log" VALUES (108, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:01.971175');
INSERT INTO "public"."launcher_download_log" VALUES (109, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:11.983603');
INSERT INTO "public"."launcher_download_log" VALUES (110, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:21.976262');
INSERT INTO "public"."launcher_download_log" VALUES (111, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:31.984577');
INSERT INTO "public"."launcher_download_log" VALUES (112, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:41.983343');
INSERT INTO "public"."launcher_download_log" VALUES (113, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:48:51.98204');
INSERT INTO "public"."launcher_download_log" VALUES (114, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:01.984059');
INSERT INTO "public"."launcher_download_log" VALUES (115, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:11.987028');
INSERT INTO "public"."launcher_download_log" VALUES (116, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:21.979024');
INSERT INTO "public"."launcher_download_log" VALUES (117, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:31.978348');
INSERT INTO "public"."launcher_download_log" VALUES (118, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:41.963872');
INSERT INTO "public"."launcher_download_log" VALUES (119, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:49:51.976198');
INSERT INTO "public"."launcher_download_log" VALUES (120, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:50:01.979297');
INSERT INTO "public"."launcher_download_log" VALUES (121, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:50:11.974109');
INSERT INTO "public"."launcher_download_log" VALUES (124, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:50:41.980478');
INSERT INTO "public"."launcher_download_log" VALUES (125, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 20:54:43.337246');
INSERT INTO "public"."launcher_download_log" VALUES (127, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:54:43.957847');
INSERT INTO "public"."launcher_download_log" VALUES (131, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:24.29519');
INSERT INTO "public"."launcher_download_log" VALUES (132, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:34.292766');
INSERT INTO "public"."launcher_download_log" VALUES (135, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:04.296754');
INSERT INTO "public"."launcher_download_log" VALUES (137, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:24.295276');
INSERT INTO "public"."launcher_download_log" VALUES (138, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:34.287048');
INSERT INTO "public"."launcher_download_log" VALUES (140, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:54.287458');
INSERT INTO "public"."launcher_download_log" VALUES (143, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:24.287538');
INSERT INTO "public"."launcher_download_log" VALUES (144, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:34.287291');
INSERT INTO "public"."launcher_download_log" VALUES (147, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:04.288021');
INSERT INTO "public"."launcher_download_log" VALUES (149, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:24.295966');
INSERT INTO "public"."launcher_download_log" VALUES (150, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:34.302425');
INSERT INTO "public"."launcher_download_log" VALUES (153, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:04.303389');
INSERT INTO "public"."launcher_download_log" VALUES (154, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:14.308835');
INSERT INTO "public"."launcher_download_log" VALUES (156, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:34.28772');
INSERT INTO "public"."launcher_download_log" VALUES (1257, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:26.608128');
INSERT INTO "public"."launcher_download_log" VALUES (1258, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:26.622976');
INSERT INTO "public"."launcher_download_log" VALUES (1260, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:47:28.648741');
INSERT INTO "public"."launcher_download_log" VALUES (1265, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:47:58.631027');
INSERT INTO "public"."launcher_download_log" VALUES (1267, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:28.625591');
INSERT INTO "public"."launcher_download_log" VALUES (1268, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:28.642204');
INSERT INTO "public"."launcher_download_log" VALUES (1270, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:28.664347');
INSERT INTO "public"."launcher_download_log" VALUES (1272, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:30.673247');
INSERT INTO "public"."launcher_download_log" VALUES (1273, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:48:56.618534');
INSERT INTO "public"."launcher_download_log" VALUES (1275, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:56.643049');
INSERT INTO "public"."launcher_download_log" VALUES (1276, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:56.659761');
INSERT INTO "public"."launcher_download_log" VALUES (1278, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:48:58.665174');
INSERT INTO "public"."launcher_download_log" VALUES (1513, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:18:35.048062');
INSERT INTO "public"."launcher_download_log" VALUES (1514, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:18:35.089145');
INSERT INTO "public"."launcher_download_log" VALUES (1516, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:09.339837');
INSERT INTO "public"."launcher_download_log" VALUES (1518, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:09.371955');
INSERT INTO "public"."launcher_download_log" VALUES (1519, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:11.340688');
INSERT INTO "public"."launcher_download_log" VALUES (1520, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:11.369407');
INSERT INTO "public"."launcher_download_log" VALUES (1522, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:39.355707');
INSERT INTO "public"."launcher_download_log" VALUES (1529, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:20:09.339811');
INSERT INTO "public"."launcher_download_log" VALUES (1531, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:20:11.324875');
INSERT INTO "public"."launcher_download_log" VALUES (1532, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:20:11.355502');
INSERT INTO "public"."launcher_download_log" VALUES (1533, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:11.783791');
INSERT INTO "public"."launcher_download_log" VALUES (1534, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:11.830863');
INSERT INTO "public"."launcher_download_log" VALUES (1541, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:47.567873');
INSERT INTO "public"."launcher_download_log" VALUES (1542, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:47.592835');
INSERT INTO "public"."launcher_download_log" VALUES (1543, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:49.959769');
INSERT INTO "public"."launcher_download_log" VALUES (1544, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:49.988018');
INSERT INTO "public"."launcher_download_log" VALUES (1553, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:47.50207');
INSERT INTO "public"."launcher_download_log" VALUES (1554, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:47.532553');
INSERT INTO "public"."launcher_download_log" VALUES (1555, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:49.91574');
INSERT INTO "public"."launcher_download_log" VALUES (1556, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:49.947049');
INSERT INTO "public"."launcher_download_log" VALUES (1557, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:17.105354');
INSERT INTO "public"."launcher_download_log" VALUES (1558, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:17.134525');
INSERT INTO "public"."launcher_download_log" VALUES (1830, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:02.922458');
INSERT INTO "public"."launcher_download_log" VALUES (1832, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:02.990467');
INSERT INTO "public"."launcher_download_log" VALUES (1833, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:00:03.092762');
INSERT INTO "public"."launcher_download_log" VALUES (1837, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:37.443576');
INSERT INTO "public"."launcher_download_log" VALUES (1839, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:00:39.471553');
INSERT INTO "public"."launcher_download_log" VALUES (1841, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:07.324825');
INSERT INTO "public"."launcher_download_log" VALUES (1842, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:07.350595');
INSERT INTO "public"."launcher_download_log" VALUES (1845, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:09.361211');
INSERT INTO "public"."launcher_download_log" VALUES (1847, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:37.410311');
INSERT INTO "public"."launcher_download_log" VALUES (1848, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:01:37.424742');
INSERT INTO "public"."launcher_download_log" VALUES (1849, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:37.442016');
INSERT INTO "public"."launcher_download_log" VALUES (1850, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:37.454234');
INSERT INTO "public"."launcher_download_log" VALUES (1852, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:01:39.477507');
INSERT INTO "public"."launcher_download_log" VALUES (1853, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:02:09.344382');
INSERT INTO "public"."launcher_download_log" VALUES (1855, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:09.395616');
INSERT INTO "public"."launcher_download_log" VALUES (1856, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:09.41641');
INSERT INTO "public"."launcher_download_log" VALUES (1858, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:11.416608');
INSERT INTO "public"."launcher_download_log" VALUES (1864, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:02:39.46203');
INSERT INTO "public"."launcher_download_log" VALUES (1866, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:13.891366');
INSERT INTO "public"."launcher_download_log" VALUES (1867, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:14.129733');
INSERT INTO "public"."launcher_download_log" VALUES (1869, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:14.205519');
INSERT INTO "public"."launcher_download_log" VALUES (1871, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:48.465872');
INSERT INTO "public"."launcher_download_log" VALUES (2053, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:43.219249');
INSERT INTO "public"."launcher_download_log" VALUES (2055, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:45.650451');
INSERT INTO "public"."launcher_download_log" VALUES (2058, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:12.812347');
INSERT INTO "public"."launcher_download_log" VALUES (2059, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:13.180213');
INSERT INTO "public"."launcher_download_log" VALUES (2061, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:15.600276');
INSERT INTO "public"."launcher_download_log" VALUES (2064, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:42.8987');
INSERT INTO "public"."launcher_download_log" VALUES (122, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:50:22.015274');
INSERT INTO "public"."launcher_download_log" VALUES (123, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:50:31.970831');
INSERT INTO "public"."launcher_download_log" VALUES (126, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 20:54:43.44683');
INSERT INTO "public"."launcher_download_log" VALUES (128, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:54:54.289106');
INSERT INTO "public"."launcher_download_log" VALUES (129, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:04.288834');
INSERT INTO "public"."launcher_download_log" VALUES (130, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:14.290582');
INSERT INTO "public"."launcher_download_log" VALUES (133, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:44.29574');
INSERT INTO "public"."launcher_download_log" VALUES (134, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:55:54.293145');
INSERT INTO "public"."launcher_download_log" VALUES (136, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:14.29448');
INSERT INTO "public"."launcher_download_log" VALUES (139, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:56:44.280085');
INSERT INTO "public"."launcher_download_log" VALUES (141, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:04.288242');
INSERT INTO "public"."launcher_download_log" VALUES (142, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:14.289033');
INSERT INTO "public"."launcher_download_log" VALUES (145, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:44.287083');
INSERT INTO "public"."launcher_download_log" VALUES (146, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:57:54.292125');
INSERT INTO "public"."launcher_download_log" VALUES (148, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:14.302912');
INSERT INTO "public"."launcher_download_log" VALUES (151, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:44.292395');
INSERT INTO "public"."launcher_download_log" VALUES (152, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:58:54.293218');
INSERT INTO "public"."launcher_download_log" VALUES (155, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:24.28525');
INSERT INTO "public"."launcher_download_log" VALUES (157, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:44.287498');
INSERT INTO "public"."launcher_download_log" VALUES (158, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 20:59:54.298381');
INSERT INTO "public"."launcher_download_log" VALUES (159, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:04.293072');
INSERT INTO "public"."launcher_download_log" VALUES (160, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:14.296123');
INSERT INTO "public"."launcher_download_log" VALUES (161, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:24.290731');
INSERT INTO "public"."launcher_download_log" VALUES (162, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:34.290617');
INSERT INTO "public"."launcher_download_log" VALUES (163, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:44.29122');
INSERT INTO "public"."launcher_download_log" VALUES (164, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:00:54.295266');
INSERT INTO "public"."launcher_download_log" VALUES (165, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:04.292222');
INSERT INTO "public"."launcher_download_log" VALUES (166, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:14.301607');
INSERT INTO "public"."launcher_download_log" VALUES (167, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:24.29796');
INSERT INTO "public"."launcher_download_log" VALUES (168, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:34.298999');
INSERT INTO "public"."launcher_download_log" VALUES (169, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:44.296975');
INSERT INTO "public"."launcher_download_log" VALUES (170, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:01:54.293215');
INSERT INTO "public"."launcher_download_log" VALUES (171, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:04.279349');
INSERT INTO "public"."launcher_download_log" VALUES (172, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:14.290753');
INSERT INTO "public"."launcher_download_log" VALUES (173, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:24.285114');
INSERT INTO "public"."launcher_download_log" VALUES (174, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:34.298733');
INSERT INTO "public"."launcher_download_log" VALUES (175, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:44.287015');
INSERT INTO "public"."launcher_download_log" VALUES (176, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:02:54.299593');
INSERT INTO "public"."launcher_download_log" VALUES (177, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:03:04.285711');
INSERT INTO "public"."launcher_download_log" VALUES (178, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:03:14.292337');
INSERT INTO "public"."launcher_download_log" VALUES (179, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:03:24.299226');
INSERT INTO "public"."launcher_download_log" VALUES (180, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:03:34.302859');
INSERT INTO "public"."launcher_download_log" VALUES (181, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:03:50.461973');
INSERT INTO "public"."launcher_download_log" VALUES (182, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:03:54.196047');
INSERT INTO "public"."launcher_download_log" VALUES (183, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:00.811315');
INSERT INTO "public"."launcher_download_log" VALUES (184, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:10.798034');
INSERT INTO "public"."launcher_download_log" VALUES (185, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:20.800643');
INSERT INTO "public"."launcher_download_log" VALUES (188, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:50.804912');
INSERT INTO "public"."launcher_download_log" VALUES (189, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:05:02.933799');
INSERT INTO "public"."launcher_download_log" VALUES (192, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:05:23.277392');
INSERT INTO "public"."launcher_download_log" VALUES (193, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:05:32.516111');
INSERT INTO "public"."launcher_download_log" VALUES (195, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:05:40.310565');
INSERT INTO "public"."launcher_download_log" VALUES (196, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:11:45.319684');
INSERT INTO "public"."launcher_download_log" VALUES (198, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:11:45.951529');
INSERT INTO "public"."launcher_download_log" VALUES (199, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:11:56.296844');
INSERT INTO "public"."launcher_download_log" VALUES (201, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:12:06.556025');
INSERT INTO "public"."launcher_download_log" VALUES (204, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:27.431128');
INSERT INTO "public"."launcher_download_log" VALUES (205, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:37.415573');
INSERT INTO "public"."launcher_download_log" VALUES (1279, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:26.63005');
INSERT INTO "public"."launcher_download_log" VALUES (1280, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:26.645072');
INSERT INTO "public"."launcher_download_log" VALUES (1281, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:26.656829');
INSERT INTO "public"."launcher_download_log" VALUES (1282, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:26.666744');
INSERT INTO "public"."launcher_download_log" VALUES (1283, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:28.656497');
INSERT INTO "public"."launcher_download_log" VALUES (1290, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:58.663574');
INSERT INTO "public"."launcher_download_log" VALUES (1291, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:53:52.140931');
INSERT INTO "public"."launcher_download_log" VALUES (1292, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:53:52.188967');
INSERT INTO "public"."launcher_download_log" VALUES (1293, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:53:52.383245');
INSERT INTO "public"."launcher_download_log" VALUES (1295, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:53:52.422528');
INSERT INTO "public"."launcher_download_log" VALUES (1296, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:53:52.436728');
INSERT INTO "public"."launcher_download_log" VALUES (1297, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:02:55.241623');
INSERT INTO "public"."launcher_download_log" VALUES (1301, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:02:55.521391');
INSERT INTO "public"."launcher_download_log" VALUES (1306, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:03:40.655128');
INSERT INTO "public"."launcher_download_log" VALUES (1308, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:03:40.708006');
INSERT INTO "public"."launcher_download_log" VALUES (1563, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:31.330105');
INSERT INTO "public"."launcher_download_log" VALUES (1564, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:31.373418');
INSERT INTO "public"."launcher_download_log" VALUES (1565, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:47.099554');
INSERT INTO "public"."launcher_download_log" VALUES (1566, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:47.129659');
INSERT INTO "public"."launcher_download_log" VALUES (1567, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:47.512471');
INSERT INTO "public"."launcher_download_log" VALUES (1568, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:47.541091');
INSERT INTO "public"."launcher_download_log" VALUES (1569, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:05:49.927699');
INSERT INTO "public"."launcher_download_log" VALUES (1570, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:05:49.959392');
INSERT INTO "public"."launcher_download_log" VALUES (1571, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:17.10005');
INSERT INTO "public"."launcher_download_log" VALUES (1572, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:17.129674');
INSERT INTO "public"."launcher_download_log" VALUES (1573, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:17.507212');
INSERT INTO "public"."launcher_download_log" VALUES (1574, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:17.532597');
INSERT INTO "public"."launcher_download_log" VALUES (1575, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:19.897457');
INSERT INTO "public"."launcher_download_log" VALUES (1576, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:19.926493');
INSERT INTO "public"."launcher_download_log" VALUES (1577, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:47.116817');
INSERT INTO "public"."launcher_download_log" VALUES (1578, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:47.144069');
INSERT INTO "public"."launcher_download_log" VALUES (1579, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:47.535342');
INSERT INTO "public"."launcher_download_log" VALUES (1580, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:47.568635');
INSERT INTO "public"."launcher_download_log" VALUES (1581, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:06:49.955211');
INSERT INTO "public"."launcher_download_log" VALUES (1582, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:06:49.985038');
INSERT INTO "public"."launcher_download_log" VALUES (1583, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:17.107564');
INSERT INTO "public"."launcher_download_log" VALUES (1584, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:17.133971');
INSERT INTO "public"."launcher_download_log" VALUES (1585, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:17.52099');
INSERT INTO "public"."launcher_download_log" VALUES (1586, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:17.546717');
INSERT INTO "public"."launcher_download_log" VALUES (1587, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:19.946693');
INSERT INTO "public"."launcher_download_log" VALUES (1588, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:19.979007');
INSERT INTO "public"."launcher_download_log" VALUES (1589, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:47.099852');
INSERT INTO "public"."launcher_download_log" VALUES (1590, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:47.132761');
INSERT INTO "public"."launcher_download_log" VALUES (1591, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:47.50959');
INSERT INTO "public"."launcher_download_log" VALUES (1592, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:47.537333');
INSERT INTO "public"."launcher_download_log" VALUES (1593, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:07:49.923202');
INSERT INTO "public"."launcher_download_log" VALUES (1594, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:07:49.950409');
INSERT INTO "public"."launcher_download_log" VALUES (1595, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:08:24.447183');
INSERT INTO "public"."launcher_download_log" VALUES (1596, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:08:24.501395');
INSERT INTO "public"."launcher_download_log" VALUES (1597, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:08:25.049466');
INSERT INTO "public"."launcher_download_log" VALUES (1598, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:08:25.083585');
INSERT INTO "public"."launcher_download_log" VALUES (1599, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:08:25.465913');
INSERT INTO "public"."launcher_download_log" VALUES (1600, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:08:25.510817');
INSERT INTO "public"."launcher_download_log" VALUES (1601, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:08:59.901892');
INSERT INTO "public"."launcher_download_log" VALUES (1602, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:08:59.927652');
INSERT INTO "public"."launcher_download_log" VALUES (1603, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:09:00.302532');
INSERT INTO "public"."launcher_download_log" VALUES (1604, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:09:00.34184');
INSERT INTO "public"."launcher_download_log" VALUES (1605, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:09:02.693084');
INSERT INTO "public"."launcher_download_log" VALUES (1606, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:09:02.72009');
INSERT INTO "public"."launcher_download_log" VALUES (1607, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:09:25.723092');
INSERT INTO "public"."launcher_download_log" VALUES (1608, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:09:25.755534');
INSERT INTO "public"."launcher_download_log" VALUES (1609, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:09:59.87967');
INSERT INTO "public"."launcher_download_log" VALUES (1610, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:09:59.910076');
INSERT INTO "public"."launcher_download_log" VALUES (1611, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:10:00.271077');
INSERT INTO "public"."launcher_download_log" VALUES (1612, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:10:00.299021');
INSERT INTO "public"."launcher_download_log" VALUES (1613, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:10:02.664224');
INSERT INTO "public"."launcher_download_log" VALUES (1614, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:10:02.688476');
INSERT INTO "public"."launcher_download_log" VALUES (1615, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:11:39.418736');
INSERT INTO "public"."launcher_download_log" VALUES (1616, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:11:39.453186');
INSERT INTO "public"."launcher_download_log" VALUES (1617, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:11:39.947785');
INSERT INTO "public"."launcher_download_log" VALUES (1618, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:11:39.985026');
INSERT INTO "public"."launcher_download_log" VALUES (1620, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:11:40.364135');
INSERT INTO "public"."launcher_download_log" VALUES (1621, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:14.678035');
INSERT INTO "public"."launcher_download_log" VALUES (1624, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:15.125839');
INSERT INTO "public"."launcher_download_log" VALUES (1625, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:17.487523');
INSERT INTO "public"."launcher_download_log" VALUES (1626, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:17.516523');
INSERT INTO "public"."launcher_download_log" VALUES (1627, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:44.808561');
INSERT INTO "public"."launcher_download_log" VALUES (1630, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:45.249373');
INSERT INTO "public"."launcher_download_log" VALUES (1632, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:47.665794');
INSERT INTO "public"."launcher_download_log" VALUES (186, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:30.795973');
INSERT INTO "public"."launcher_download_log" VALUES (187, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:04:40.803921');
INSERT INTO "public"."launcher_download_log" VALUES (190, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:05:03.916695');
INSERT INTO "public"."launcher_download_log" VALUES (191, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:05:13.268567');
INSERT INTO "public"."launcher_download_log" VALUES (194, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:05:33.177567');
INSERT INTO "public"."launcher_download_log" VALUES (197, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:11:45.422989');
INSERT INTO "public"."launcher_download_log" VALUES (200, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:12:06.465996');
INSERT INTO "public"."launcher_download_log" VALUES (202, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:07.089812');
INSERT INTO "public"."launcher_download_log" VALUES (203, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:17.433638');
INSERT INTO "public"."launcher_download_log" VALUES (206, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:47.410691');
INSERT INTO "public"."launcher_download_log" VALUES (207, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:12:57.435122');
INSERT INTO "public"."launcher_download_log" VALUES (208, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:13:10.393242');
INSERT INTO "public"."launcher_download_log" VALUES (209, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:13:10.506456');
INSERT INTO "public"."launcher_download_log" VALUES (210, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:13:11.006081');
INSERT INTO "public"."launcher_download_log" VALUES (211, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:13:21.497437');
INSERT INTO "public"."launcher_download_log" VALUES (212, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:13:31.335625');
INSERT INTO "public"."launcher_download_log" VALUES (213, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:13:41.33603');
INSERT INTO "public"."launcher_download_log" VALUES (214, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:13:51.342939');
INSERT INTO "public"."launcher_download_log" VALUES (215, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:14:01.347824');
INSERT INTO "public"."launcher_download_log" VALUES (216, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:14:11.326381');
INSERT INTO "public"."launcher_download_log" VALUES (217, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:14:21.33903');
INSERT INTO "public"."launcher_download_log" VALUES (218, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:14:31.336283');
INSERT INTO "public"."launcher_download_log" VALUES (219, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:15:07.53864');
INSERT INTO "public"."launcher_download_log" VALUES (220, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:15:07.641655');
INSERT INTO "public"."launcher_download_log" VALUES (221, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:08.151095');
INSERT INTO "public"."launcher_download_log" VALUES (222, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:18.496573');
INSERT INTO "public"."launcher_download_log" VALUES (223, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:28.490854');
INSERT INTO "public"."launcher_download_log" VALUES (224, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:38.475037');
INSERT INTO "public"."launcher_download_log" VALUES (225, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:48.541612');
INSERT INTO "public"."launcher_download_log" VALUES (226, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:15:58.479889');
INSERT INTO "public"."launcher_download_log" VALUES (227, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:16:08.548313');
INSERT INTO "public"."launcher_download_log" VALUES (228, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:16:22.166028');
INSERT INTO "public"."launcher_download_log" VALUES (229, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:16:22.249091');
INSERT INTO "public"."launcher_download_log" VALUES (230, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:16:22.773233');
INSERT INTO "public"."launcher_download_log" VALUES (231, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:16:33.111032');
INSERT INTO "public"."launcher_download_log" VALUES (232, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:16:43.096183');
INSERT INTO "public"."launcher_download_log" VALUES (233, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:16:53.624621');
INSERT INTO "public"."launcher_download_log" VALUES (234, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:17:19.531349');
INSERT INTO "public"."launcher_download_log" VALUES (235, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:17:19.589766');
INSERT INTO "public"."launcher_download_log" VALUES (236, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:17:20.145857');
INSERT INTO "public"."launcher_download_log" VALUES (237, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:17:21.285577');
INSERT INTO "public"."launcher_download_log" VALUES (238, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:23:35.145208');
INSERT INTO "public"."launcher_download_log" VALUES (239, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:23:35.269226');
INSERT INTO "public"."launcher_download_log" VALUES (240, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:23:35.774371');
INSERT INTO "public"."launcher_download_log" VALUES (241, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:23:46.160038');
INSERT INTO "public"."launcher_download_log" VALUES (242, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:23:56.125042');
INSERT INTO "public"."launcher_download_log" VALUES (243, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:06.63925');
INSERT INTO "public"."launcher_download_log" VALUES (244, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:16.121396');
INSERT INTO "public"."launcher_download_log" VALUES (245, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:26.131275');
INSERT INTO "public"."launcher_download_log" VALUES (246, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:36.115344');
INSERT INTO "public"."launcher_download_log" VALUES (247, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:46.130594');
INSERT INTO "public"."launcher_download_log" VALUES (248, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:24:56.117843');
INSERT INTO "public"."launcher_download_log" VALUES (249, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:06.131196');
INSERT INTO "public"."launcher_download_log" VALUES (252, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:36.118509');
INSERT INTO "public"."launcher_download_log" VALUES (253, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:46.11613');
INSERT INTO "public"."launcher_download_log" VALUES (256, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:16.122542');
INSERT INTO "public"."launcher_download_log" VALUES (257, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:26.113464');
INSERT INTO "public"."launcher_download_log" VALUES (259, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:46.126132');
INSERT INTO "public"."launcher_download_log" VALUES (262, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:16.119981');
INSERT INTO "public"."launcher_download_log" VALUES (263, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:26.12842');
INSERT INTO "public"."launcher_download_log" VALUES (265, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:46.128152');
INSERT INTO "public"."launcher_download_log" VALUES (268, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:16.121763');
INSERT INTO "public"."launcher_download_log" VALUES (269, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:26.124215');
INSERT INTO "public"."launcher_download_log" VALUES (271, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:46.113129');
INSERT INTO "public"."launcher_download_log" VALUES (274, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:16.120642');
INSERT INTO "public"."launcher_download_log" VALUES (276, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:36.122436');
INSERT INTO "public"."launcher_download_log" VALUES (277, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:46.118793');
INSERT INTO "public"."launcher_download_log" VALUES (1284, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:28.678435');
INSERT INTO "public"."launcher_download_log" VALUES (1285, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:56.608829');
INSERT INTO "public"."launcher_download_log" VALUES (1286, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:56.626384');
INSERT INTO "public"."launcher_download_log" VALUES (1287, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:56.639685');
INSERT INTO "public"."launcher_download_log" VALUES (1288, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:49:56.648319');
INSERT INTO "public"."launcher_download_log" VALUES (1289, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:49:58.643203');
INSERT INTO "public"."launcher_download_log" VALUES (1294, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:53:52.402092');
INSERT INTO "public"."launcher_download_log" VALUES (1298, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:02:55.277735');
INSERT INTO "public"."launcher_download_log" VALUES (1299, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:02:55.435592');
INSERT INTO "public"."launcher_download_log" VALUES (1300, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:02:55.491906');
INSERT INTO "public"."launcher_download_log" VALUES (1303, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:03:40.320834');
INSERT INTO "public"."launcher_download_log" VALUES (1304, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:03:40.363006');
INSERT INTO "public"."launcher_download_log" VALUES (1305, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 22:03:40.654705');
INSERT INTO "public"."launcher_download_log" VALUES (1307, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:03:40.707697');
INSERT INTO "public"."launcher_download_log" VALUES (1619, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:11:40.275134');
INSERT INTO "public"."launcher_download_log" VALUES (1622, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:14.712841');
INSERT INTO "public"."launcher_download_log" VALUES (1623, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:15.095202');
INSERT INTO "public"."launcher_download_log" VALUES (1628, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:12:44.842954');
INSERT INTO "public"."launcher_download_log" VALUES (1629, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:45.221873');
INSERT INTO "public"."launcher_download_log" VALUES (1631, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:12:47.637177');
INSERT INTO "public"."launcher_download_log" VALUES (1634, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:14.665123');
INSERT INTO "public"."launcher_download_log" VALUES (1635, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:15.042048');
INSERT INTO "public"."launcher_download_log" VALUES (1637, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:17.469852');
INSERT INTO "public"."launcher_download_log" VALUES (1640, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:44.693154');
INSERT INTO "public"."launcher_download_log" VALUES (1641, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:45.112588');
INSERT INTO "public"."launcher_download_log" VALUES (1643, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:48.629033');
INSERT INTO "public"."launcher_download_log" VALUES (1645, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:14.707933');
INSERT INTO "public"."launcher_download_log" VALUES (1648, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:15.134945');
INSERT INTO "public"."launcher_download_log" VALUES (1649, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:17.583456');
INSERT INTO "public"."launcher_download_log" VALUES (1652, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:44.693986');
INSERT INTO "public"."launcher_download_log" VALUES (1653, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:45.085462');
INSERT INTO "public"."launcher_download_log" VALUES (1873, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:48.505474');
INSERT INTO "public"."launcher_download_log" VALUES (1874, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:48.530263');
INSERT INTO "public"."launcher_download_log" VALUES (2063, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:42.842337');
INSERT INTO "public"."launcher_download_log" VALUES (2066, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:43.373941');
INSERT INTO "public"."launcher_download_log" VALUES (2068, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:45.780823');
INSERT INTO "public"."launcher_download_log" VALUES (2069, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:14:08.605479');
INSERT INTO "public"."launcher_download_log" VALUES (2072, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:14:42.769992');
INSERT INTO "public"."launcher_download_log" VALUES (2073, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:14:43.136441');
INSERT INTO "public"."launcher_download_log" VALUES (2075, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:14:45.552482');
INSERT INTO "public"."launcher_download_log" VALUES (2077, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:17:38.296945');
INSERT INTO "public"."launcher_download_log" VALUES (2079, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:17:38.993164');
INSERT INTO "public"."launcher_download_log" VALUES (2081, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:17:39.443114');
INSERT INTO "public"."launcher_download_log" VALUES (2083, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:18:03.834369');
INSERT INTO "public"."launcher_download_log" VALUES (2085, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:22:15.248103');
INSERT INTO "public"."launcher_download_log" VALUES (2087, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:22:15.371969');
INSERT INTO "public"."launcher_download_log" VALUES (2089, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:22:15.635921');
INSERT INTO "public"."launcher_download_log" VALUES (2091, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:22:15.667433');
INSERT INTO "public"."launcher_download_log" VALUES (2093, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:22:15.779644');
INSERT INTO "public"."launcher_download_log" VALUES (2094, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:22:15.79064');
INSERT INTO "public"."launcher_download_log" VALUES (2095, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:23:42.521935');
INSERT INTO "public"."launcher_download_log" VALUES (2096, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:23:42.578026');
INSERT INTO "public"."launcher_download_log" VALUES (2113, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:26:35.190703');
INSERT INTO "public"."launcher_download_log" VALUES (2159, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:07.709438');
INSERT INTO "public"."launcher_download_log" VALUES (2160, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:07.740192');
INSERT INTO "public"."launcher_download_log" VALUES (2161, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:07.938956');
INSERT INTO "public"."launcher_download_log" VALUES (2162, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:07.955414');
INSERT INTO "public"."launcher_download_log" VALUES (2163, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:42.130537');
INSERT INTO "public"."launcher_download_log" VALUES (2169, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:16.819452');
INSERT INTO "public"."launcher_download_log" VALUES (2171, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:17.054518');
INSERT INTO "public"."launcher_download_log" VALUES (2172, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:17.118122');
INSERT INTO "public"."launcher_download_log" VALUES (2173, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:17.352269');
INSERT INTO "public"."launcher_download_log" VALUES (2175, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:51.632765');
INSERT INTO "public"."launcher_download_log" VALUES (2188, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:58:26.644178');
INSERT INTO "public"."launcher_download_log" VALUES (2190, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:58:26.766451');
INSERT INTO "public"."launcher_download_log" VALUES (250, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:16.127876');
INSERT INTO "public"."launcher_download_log" VALUES (251, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:26.132283');
INSERT INTO "public"."launcher_download_log" VALUES (254, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:25:56.1081');
INSERT INTO "public"."launcher_download_log" VALUES (255, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:06.116893');
INSERT INTO "public"."launcher_download_log" VALUES (258, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:36.122287');
INSERT INTO "public"."launcher_download_log" VALUES (260, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:26:56.121198');
INSERT INTO "public"."launcher_download_log" VALUES (261, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:06.13048');
INSERT INTO "public"."launcher_download_log" VALUES (264, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:36.124566');
INSERT INTO "public"."launcher_download_log" VALUES (266, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:27:56.116135');
INSERT INTO "public"."launcher_download_log" VALUES (267, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:06.133837');
INSERT INTO "public"."launcher_download_log" VALUES (270, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:36.109886');
INSERT INTO "public"."launcher_download_log" VALUES (272, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:28:56.118393');
INSERT INTO "public"."launcher_download_log" VALUES (273, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:06.117938');
INSERT INTO "public"."launcher_download_log" VALUES (275, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:26.129777');
INSERT INTO "public"."launcher_download_log" VALUES (278, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:29:56.78398');
INSERT INTO "public"."launcher_download_log" VALUES (279, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:30:09.492738');
INSERT INTO "public"."launcher_download_log" VALUES (280, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:30:09.605154');
INSERT INTO "public"."launcher_download_log" VALUES (281, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:30:10.113556');
INSERT INTO "public"."launcher_download_log" VALUES (282, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:30:20.451148');
INSERT INTO "public"."launcher_download_log" VALUES (283, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:30:30.455388');
INSERT INTO "public"."launcher_download_log" VALUES (284, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:30:40.449071');
INSERT INTO "public"."launcher_download_log" VALUES (285, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:30:50.455848');
INSERT INTO "public"."launcher_download_log" VALUES (286, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:00.452229');
INSERT INTO "public"."launcher_download_log" VALUES (287, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:10.446215');
INSERT INTO "public"."launcher_download_log" VALUES (288, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:20.448807');
INSERT INTO "public"."launcher_download_log" VALUES (289, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:30.453332');
INSERT INTO "public"."launcher_download_log" VALUES (290, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:40.45018');
INSERT INTO "public"."launcher_download_log" VALUES (291, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:31:50.445437');
INSERT INTO "public"."launcher_download_log" VALUES (292, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:00.766172');
INSERT INTO "public"."launcher_download_log" VALUES (293, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:10.44036');
INSERT INTO "public"."launcher_download_log" VALUES (294, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:20.456035');
INSERT INTO "public"."launcher_download_log" VALUES (295, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:30.453573');
INSERT INTO "public"."launcher_download_log" VALUES (296, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:32:47.352735');
INSERT INTO "public"."launcher_download_log" VALUES (297, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:32:47.448735');
INSERT INTO "public"."launcher_download_log" VALUES (298, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:47.978473');
INSERT INTO "public"."launcher_download_log" VALUES (299, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:32:58.310257');
INSERT INTO "public"."launcher_download_log" VALUES (300, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:40:00.739332');
INSERT INTO "public"."launcher_download_log" VALUES (301, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:40:01.660415');
INSERT INTO "public"."launcher_download_log" VALUES (302, '127.0.0.1', 'GameLauncher/1.0', 'launcher_update', 'launcher_check', 't', '2025-06-01 21:40:31.114863');
INSERT INTO "public"."launcher_download_log" VALUES (303, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-01 21:40:31.231873');
INSERT INTO "public"."launcher_download_log" VALUES (304, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:40:31.733614');
INSERT INTO "public"."launcher_download_log" VALUES (305, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:40:42.062543');
INSERT INTO "public"."launcher_download_log" VALUES (306, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:40:52.058985');
INSERT INTO "public"."launcher_download_log" VALUES (307, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:02.066312');
INSERT INTO "public"."launcher_download_log" VALUES (308, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:12.0644');
INSERT INTO "public"."launcher_download_log" VALUES (309, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:22.073337');
INSERT INTO "public"."launcher_download_log" VALUES (310, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:32.066201');
INSERT INTO "public"."launcher_download_log" VALUES (311, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:42.070159');
INSERT INTO "public"."launcher_download_log" VALUES (484, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:53:48.163493');
INSERT INTO "public"."launcher_download_log" VALUES (312, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:41:52.073153');
INSERT INTO "public"."launcher_download_log" VALUES (314, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:12.068905');
INSERT INTO "public"."launcher_download_log" VALUES (315, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:22.070487');
INSERT INTO "public"."launcher_download_log" VALUES (318, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:52.066805');
INSERT INTO "public"."launcher_download_log" VALUES (320, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:12.067014');
INSERT INTO "public"."launcher_download_log" VALUES (321, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:22.057512');
INSERT INTO "public"."launcher_download_log" VALUES (323, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:42.06156');
INSERT INTO "public"."launcher_download_log" VALUES (326, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:12.07115');
INSERT INTO "public"."launcher_download_log" VALUES (327, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:22.06802');
INSERT INTO "public"."launcher_download_log" VALUES (330, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:52.069203');
INSERT INTO "public"."launcher_download_log" VALUES (331, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:02.075362');
INSERT INTO "public"."launcher_download_log" VALUES (334, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:32.065098');
INSERT INTO "public"."launcher_download_log" VALUES (336, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:52.053387');
INSERT INTO "public"."launcher_download_log" VALUES (338, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:12.057948');
INSERT INTO "public"."launcher_download_log" VALUES (339, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:22.060454');
INSERT INTO "public"."launcher_download_log" VALUES (341, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:42.058678');
INSERT INTO "public"."launcher_download_log" VALUES (344, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:12.071722');
INSERT INTO "public"."launcher_download_log" VALUES (345, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:22.06173');
INSERT INTO "public"."launcher_download_log" VALUES (348, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:52.058975');
INSERT INTO "public"."launcher_download_log" VALUES (349, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:02.071998');
INSERT INTO "public"."launcher_download_log" VALUES (352, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:32.075358');
INSERT INTO "public"."launcher_download_log" VALUES (353, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:42.057658');
INSERT INTO "public"."launcher_download_log" VALUES (356, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:12.060972');
INSERT INTO "public"."launcher_download_log" VALUES (357, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:22.065982');
INSERT INTO "public"."launcher_download_log" VALUES (360, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:52.070769');
INSERT INTO "public"."launcher_download_log" VALUES (361, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:02.069072');
INSERT INTO "public"."launcher_download_log" VALUES (364, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:32.064375');
INSERT INTO "public"."launcher_download_log" VALUES (365, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:42.065276');
INSERT INTO "public"."launcher_download_log" VALUES (368, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:12.069357');
INSERT INTO "public"."launcher_download_log" VALUES (370, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:32.068629');
INSERT INTO "public"."launcher_download_log" VALUES (372, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:52.064448');
INSERT INTO "public"."launcher_download_log" VALUES (373, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:02.061056');
INSERT INTO "public"."launcher_download_log" VALUES (376, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:32.059462');
INSERT INTO "public"."launcher_download_log" VALUES (377, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:42.075055');
INSERT INTO "public"."launcher_download_log" VALUES (379, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:02.063111');
INSERT INTO "public"."launcher_download_log" VALUES (381, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:22.06268');
INSERT INTO "public"."launcher_download_log" VALUES (383, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:42.079441');
INSERT INTO "public"."launcher_download_log" VALUES (1302, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 22:02:55.547726');
INSERT INTO "public"."launcher_download_log" VALUES (1633, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:14.637887');
INSERT INTO "public"."launcher_download_log" VALUES (1636, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:15.067842');
INSERT INTO "public"."launcher_download_log" VALUES (1638, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:17.49616');
INSERT INTO "public"."launcher_download_log" VALUES (1639, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:13:44.663712');
INSERT INTO "public"."launcher_download_log" VALUES (1642, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:45.142521');
INSERT INTO "public"."launcher_download_log" VALUES (1644, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:13:48.658291');
INSERT INTO "public"."launcher_download_log" VALUES (1646, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:14.736971');
INSERT INTO "public"."launcher_download_log" VALUES (1647, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:15.102644');
INSERT INTO "public"."launcher_download_log" VALUES (1650, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:17.613361');
INSERT INTO "public"."launcher_download_log" VALUES (1651, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:44.664949');
INSERT INTO "public"."launcher_download_log" VALUES (1654, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:45.122206');
INSERT INTO "public"."launcher_download_log" VALUES (1875, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:03:50.53459');
INSERT INTO "public"."launcher_download_log" VALUES (1876, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:03:50.559847');
INSERT INTO "public"."launcher_download_log" VALUES (1878, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:18.482539');
INSERT INTO "public"."launcher_download_log" VALUES (1880, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:18.509551');
INSERT INTO "public"."launcher_download_log" VALUES (1884, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:48.517661');
INSERT INTO "public"."launcher_download_log" VALUES (1886, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:48.546055');
INSERT INTO "public"."launcher_download_log" VALUES (1887, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:50.532687');
INSERT INTO "public"."launcher_download_log" VALUES (313, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:02.066536');
INSERT INTO "public"."launcher_download_log" VALUES (316, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:32.067818');
INSERT INTO "public"."launcher_download_log" VALUES (317, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:42:42.071142');
INSERT INTO "public"."launcher_download_log" VALUES (319, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:02.067959');
INSERT INTO "public"."launcher_download_log" VALUES (322, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:32.065333');
INSERT INTO "public"."launcher_download_log" VALUES (324, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:43:52.061175');
INSERT INTO "public"."launcher_download_log" VALUES (325, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:02.062947');
INSERT INTO "public"."launcher_download_log" VALUES (328, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:32.074031');
INSERT INTO "public"."launcher_download_log" VALUES (329, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:44:42.065682');
INSERT INTO "public"."launcher_download_log" VALUES (332, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:12.069943');
INSERT INTO "public"."launcher_download_log" VALUES (333, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:22.075298');
INSERT INTO "public"."launcher_download_log" VALUES (335, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:45:42.066186');
INSERT INTO "public"."launcher_download_log" VALUES (337, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:02.060522');
INSERT INTO "public"."launcher_download_log" VALUES (340, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:32.060687');
INSERT INTO "public"."launcher_download_log" VALUES (342, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:46:52.060815');
INSERT INTO "public"."launcher_download_log" VALUES (343, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:02.063556');
INSERT INTO "public"."launcher_download_log" VALUES (346, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:32.074277');
INSERT INTO "public"."launcher_download_log" VALUES (347, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:47:42.07155');
INSERT INTO "public"."launcher_download_log" VALUES (350, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:12.076584');
INSERT INTO "public"."launcher_download_log" VALUES (351, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:22.078303');
INSERT INTO "public"."launcher_download_log" VALUES (354, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:48:52.063289');
INSERT INTO "public"."launcher_download_log" VALUES (355, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:02.061182');
INSERT INTO "public"."launcher_download_log" VALUES (358, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:32.060042');
INSERT INTO "public"."launcher_download_log" VALUES (359, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:49:42.068253');
INSERT INTO "public"."launcher_download_log" VALUES (362, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:12.07193');
INSERT INTO "public"."launcher_download_log" VALUES (363, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:22.077068');
INSERT INTO "public"."launcher_download_log" VALUES (366, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:50:52.069501');
INSERT INTO "public"."launcher_download_log" VALUES (367, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:02.067621');
INSERT INTO "public"."launcher_download_log" VALUES (369, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:22.058129');
INSERT INTO "public"."launcher_download_log" VALUES (371, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:51:42.069658');
INSERT INTO "public"."launcher_download_log" VALUES (374, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:12.069755');
INSERT INTO "public"."launcher_download_log" VALUES (375, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:22.0636');
INSERT INTO "public"."launcher_download_log" VALUES (378, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:52:52.072086');
INSERT INTO "public"."launcher_download_log" VALUES (380, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:12.070888');
INSERT INTO "public"."launcher_download_log" VALUES (382, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:32.061944');
INSERT INTO "public"."launcher_download_log" VALUES (384, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:53:52.068215');
INSERT INTO "public"."launcher_download_log" VALUES (385, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:02.06982');
INSERT INTO "public"."launcher_download_log" VALUES (386, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:12.056706');
INSERT INTO "public"."launcher_download_log" VALUES (387, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:22.060322');
INSERT INTO "public"."launcher_download_log" VALUES (388, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:32.058435');
INSERT INTO "public"."launcher_download_log" VALUES (389, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:42.062472');
INSERT INTO "public"."launcher_download_log" VALUES (390, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:54:52.072324');
INSERT INTO "public"."launcher_download_log" VALUES (391, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:02.067622');
INSERT INTO "public"."launcher_download_log" VALUES (392, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:12.07304');
INSERT INTO "public"."launcher_download_log" VALUES (393, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:22.073048');
INSERT INTO "public"."launcher_download_log" VALUES (394, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:32.067902');
INSERT INTO "public"."launcher_download_log" VALUES (395, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:42.068835');
INSERT INTO "public"."launcher_download_log" VALUES (397, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:02.067914');
INSERT INTO "public"."launcher_download_log" VALUES (400, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:32.070807');
INSERT INTO "public"."launcher_download_log" VALUES (401, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:42.0621');
INSERT INTO "public"."launcher_download_log" VALUES (403, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 23:56:46.880908');
INSERT INTO "public"."launcher_download_log" VALUES (404, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 23:56:57.209188');
INSERT INTO "public"."launcher_download_log" VALUES (409, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 00:08:00.108099');
INSERT INTO "public"."launcher_download_log" VALUES (411, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:00.64017');
INSERT INTO "public"."launcher_download_log" VALUES (412, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:10.998218');
INSERT INTO "public"."launcher_download_log" VALUES (415, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:40.971892');
INSERT INTO "public"."launcher_download_log" VALUES (416, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:50.979979');
INSERT INTO "public"."launcher_download_log" VALUES (418, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:10.982832');
INSERT INTO "public"."launcher_download_log" VALUES (421, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:40.974377');
INSERT INTO "public"."launcher_download_log" VALUES (422, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:50.973991');
INSERT INTO "public"."launcher_download_log" VALUES (425, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:10:20.969907');
INSERT INTO "public"."launcher_download_log" VALUES (1309, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:10.960707');
INSERT INTO "public"."launcher_download_log" VALUES (1310, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:11.017171');
INSERT INTO "public"."launcher_download_log" VALUES (1311, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:11.21625');
INSERT INTO "public"."launcher_download_log" VALUES (1312, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:11.245614');
INSERT INTO "public"."launcher_download_log" VALUES (1314, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:11.303642');
INSERT INTO "public"."launcher_download_log" VALUES (1329, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:45.649688');
INSERT INTO "public"."launcher_download_log" VALUES (1331, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:45.684138');
INSERT INTO "public"."launcher_download_log" VALUES (1332, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:47.704379');
INSERT INTO "public"."launcher_download_log" VALUES (1333, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:47.727866');
INSERT INTO "public"."launcher_download_log" VALUES (1334, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:49.199328');
INSERT INTO "public"."launcher_download_log" VALUES (1337, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:09:42.298936');
INSERT INTO "public"."launcher_download_log" VALUES (1338, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:09:42.328006');
INSERT INTO "public"."launcher_download_log" VALUES (1340, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:09:45.776021');
INSERT INTO "public"."launcher_download_log" VALUES (1351, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:45.662016');
INSERT INTO "public"."launcher_download_log" VALUES (1352, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:45.679454');
INSERT INTO "public"."launcher_download_log" VALUES (1357, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:12:28.453172');
INSERT INTO "public"."launcher_download_log" VALUES (1359, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:12:28.740437');
INSERT INTO "public"."launcher_download_log" VALUES (1360, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:12:28.75759');
INSERT INTO "public"."launcher_download_log" VALUES (1362, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:12:28.784096');
INSERT INTO "public"."launcher_download_log" VALUES (1363, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:03.135917');
INSERT INTO "public"."launcher_download_log" VALUES (1365, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:03.19344');
INSERT INTO "public"."launcher_download_log" VALUES (1366, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:03.213157');
INSERT INTO "public"."launcher_download_log" VALUES (1367, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:05.18893');
INSERT INTO "public"."launcher_download_log" VALUES (1368, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:05.213574');
INSERT INTO "public"."launcher_download_log" VALUES (1379, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:59.290395');
INSERT INTO "public"."launcher_download_log" VALUES (1380, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:59.312013');
INSERT INTO "public"."launcher_download_log" VALUES (1383, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:03.249289');
INSERT INTO "public"."launcher_download_log" VALUES (1395, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:03.190819');
INSERT INTO "public"."launcher_download_log" VALUES (1398, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:03.225078');
INSERT INTO "public"."launcher_download_log" VALUES (1399, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:05.221458');
INSERT INTO "public"."launcher_download_log" VALUES (1400, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:05.243565');
INSERT INTO "public"."launcher_download_log" VALUES (1408, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:08.760719');
INSERT INTO "public"."launcher_download_log" VALUES (1410, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:08.991428');
INSERT INTO "public"."launcher_download_log" VALUES (1411, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:09.024425');
INSERT INTO "public"."launcher_download_log" VALUES (1413, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:43.35189');
INSERT INTO "public"."launcher_download_log" VALUES (1421, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:13.368045');
INSERT INTO "public"."launcher_download_log" VALUES (1422, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:13.389985');
INSERT INTO "public"."launcher_download_log" VALUES (1423, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:15.364733');
INSERT INTO "public"."launcher_download_log" VALUES (1424, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:15.386944');
INSERT INTO "public"."launcher_download_log" VALUES (1433, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:15.426812');
INSERT INTO "public"."launcher_download_log" VALUES (1439, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:43.372382');
INSERT INTO "public"."launcher_download_log" VALUES (1446, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:13.497118');
INSERT INTO "public"."launcher_download_log" VALUES (1451, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:43.366278');
INSERT INTO "public"."launcher_download_log" VALUES (1454, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:43.399461');
INSERT INTO "public"."launcher_download_log" VALUES (1655, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:14:47.512755');
INSERT INTO "public"."launcher_download_log" VALUES (1658, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:15:14.805916');
INSERT INTO "public"."launcher_download_log" VALUES (1877, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:18.448212');
INSERT INTO "public"."launcher_download_log" VALUES (1881, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:20.503612');
INSERT INTO "public"."launcher_download_log" VALUES (1882, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:20.525785');
INSERT INTO "public"."launcher_download_log" VALUES (1885, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:48.519537');
INSERT INTO "public"."launcher_download_log" VALUES (1890, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:05:20.542809');
INSERT INTO "public"."launcher_download_log" VALUES (1892, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:05:20.574868');
INSERT INTO "public"."launcher_download_log" VALUES (1893, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:05:22.568095');
INSERT INTO "public"."launcher_download_log" VALUES (1894, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:05:22.592685');
INSERT INTO "public"."launcher_download_log" VALUES (1896, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:07:56.45297');
INSERT INTO "public"."launcher_download_log" VALUES (1900, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:07:56.668416');
INSERT INTO "public"."launcher_download_log" VALUES (1901, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:08:31.057172');
INSERT INTO "public"."launcher_download_log" VALUES (1908, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:09:01.058232');
INSERT INTO "public"."launcher_download_log" VALUES (1910, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:09:01.088762');
INSERT INTO "public"."launcher_download_log" VALUES (1911, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:09:03.034929');
INSERT INTO "public"."launcher_download_log" VALUES (1912, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:09:03.067076');
INSERT INTO "public"."launcher_download_log" VALUES (1914, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:13:46.011661');
INSERT INTO "public"."launcher_download_log" VALUES (1917, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:13:46.06381');
INSERT INTO "public"."launcher_download_log" VALUES (2065, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:43.325549');
INSERT INTO "public"."launcher_download_log" VALUES (2067, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:45.736746');
INSERT INTO "public"."launcher_download_log" VALUES (2070, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:14:08.6457');
INSERT INTO "public"."launcher_download_log" VALUES (2071, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:14:42.728019');
INSERT INTO "public"."launcher_download_log" VALUES (396, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:55:52.067027');
INSERT INTO "public"."launcher_download_log" VALUES (398, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:12.069544');
INSERT INTO "public"."launcher_download_log" VALUES (399, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:22.078568');
INSERT INTO "public"."launcher_download_log" VALUES (402, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 21:56:52.066126');
INSERT INTO "public"."launcher_download_log" VALUES (405, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 23:57:07.217144');
INSERT INTO "public"."launcher_download_log" VALUES (406, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 23:57:17.222741');
INSERT INTO "public"."launcher_download_log" VALUES (407, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-01 23:58:13.517445');
INSERT INTO "public"."launcher_download_log" VALUES (408, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:02:07.30783');
INSERT INTO "public"."launcher_download_log" VALUES (410, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-02 00:08:00.152015');
INSERT INTO "public"."launcher_download_log" VALUES (413, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:20.968444');
INSERT INTO "public"."launcher_download_log" VALUES (414, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:08:30.969419');
INSERT INTO "public"."launcher_download_log" VALUES (417, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:00.964919');
INSERT INTO "public"."launcher_download_log" VALUES (419, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:20.965952');
INSERT INTO "public"."launcher_download_log" VALUES (420, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:09:30.978782');
INSERT INTO "public"."launcher_download_log" VALUES (423, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:10:00.977898');
INSERT INTO "public"."launcher_download_log" VALUES (424, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:10:10.966409');
INSERT INTO "public"."launcher_download_log" VALUES (426, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 00:44:00.210305');
INSERT INTO "public"."launcher_download_log" VALUES (427, '127.0.0.1', 'GameLauncher/1.0', 'update', 'update_check', 't', '2025-06-02 00:44:00.812525');
INSERT INTO "public"."launcher_download_log" VALUES (428, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 00:44:01.92877');
INSERT INTO "public"."launcher_download_log" VALUES (429, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:06:26.414029');
INSERT INTO "public"."launcher_download_log" VALUES (430, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:06:31.909236');
INSERT INTO "public"."launcher_download_log" VALUES (431, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:08:28.705495');
INSERT INTO "public"."launcher_download_log" VALUES (432, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:08:29.746816');
INSERT INTO "public"."launcher_download_log" VALUES (433, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 01:08:47.469009');
INSERT INTO "public"."launcher_download_log" VALUES (434, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:08:47.519159');
INSERT INTO "public"."launcher_download_log" VALUES (435, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:08:48.37019');
INSERT INTO "public"."launcher_download_log" VALUES (436, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 01:10:06.180603');
INSERT INTO "public"."launcher_download_log" VALUES (437, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:10:06.232491');
INSERT INTO "public"."launcher_download_log" VALUES (438, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:10:07.071505');
INSERT INTO "public"."launcher_download_log" VALUES (439, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 01:11:34.613066');
INSERT INTO "public"."launcher_download_log" VALUES (440, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:11:34.660712');
INSERT INTO "public"."launcher_download_log" VALUES (441, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:11:35.512913');
INSERT INTO "public"."launcher_download_log" VALUES (442, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 01:12:45.607086');
INSERT INTO "public"."launcher_download_log" VALUES (443, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:12:45.653251');
INSERT INTO "public"."launcher_download_log" VALUES (444, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', 'message', 'messages', 't', '2025-06-02 01:12:46.517225');
INSERT INTO "public"."launcher_download_log" VALUES (445, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 01:29:17.660114');
INSERT INTO "public"."launcher_download_log" VALUES (446, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 01:29:17.69546');
INSERT INTO "public"."launcher_download_log" VALUES (447, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:03:58.81482');
INSERT INTO "public"."launcher_download_log" VALUES (448, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:04:12.236715');
INSERT INTO "public"."launcher_download_log" VALUES (449, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:05:29.244331');
INSERT INTO "public"."launcher_download_log" VALUES (450, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:09:21.202798');
INSERT INTO "public"."launcher_download_log" VALUES (451, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:10:57.140599');
INSERT INTO "public"."launcher_download_log" VALUES (452, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:14:08.864815');
INSERT INTO "public"."launcher_download_log" VALUES (453, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:14:08.904138');
INSERT INTO "public"."launcher_download_log" VALUES (454, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:17:57.718362');
INSERT INTO "public"."launcher_download_log" VALUES (455, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:17:57.760599');
INSERT INTO "public"."launcher_download_log" VALUES (456, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:22:34.42907');
INSERT INTO "public"."launcher_download_log" VALUES (457, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:22:34.494834');
INSERT INTO "public"."launcher_download_log" VALUES (458, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:24:35.423952');
INSERT INTO "public"."launcher_download_log" VALUES (459, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:24:35.475585');
INSERT INTO "public"."launcher_download_log" VALUES (460, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:29:17.20899');
INSERT INTO "public"."launcher_download_log" VALUES (461, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:29:17.26054');
INSERT INTO "public"."launcher_download_log" VALUES (462, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 03:31:08.215321');
INSERT INTO "public"."launcher_download_log" VALUES (463, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 03:31:08.258064');
INSERT INTO "public"."launcher_download_log" VALUES (464, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-02 05:30:40.359906');
INSERT INTO "public"."launcher_download_log" VALUES (465, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-02 05:30:40.419966');
INSERT INTO "public"."launcher_download_log" VALUES (466, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:22:11.994163');
INSERT INTO "public"."launcher_download_log" VALUES (467, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:22:12.063542');
INSERT INTO "public"."launcher_download_log" VALUES (468, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:28:35.56662');
INSERT INTO "public"."launcher_download_log" VALUES (469, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:28:35.60575');
INSERT INTO "public"."launcher_download_log" VALUES (470, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:29:46.628112');
INSERT INTO "public"."launcher_download_log" VALUES (471, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:29:46.673763');
INSERT INTO "public"."launcher_download_log" VALUES (472, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:30:46.335627');
INSERT INTO "public"."launcher_download_log" VALUES (473, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:30:46.377036');
INSERT INTO "public"."launcher_download_log" VALUES (474, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:39:08.56346');
INSERT INTO "public"."launcher_download_log" VALUES (475, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:39:08.607438');
INSERT INTO "public"."launcher_download_log" VALUES (476, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:41:00.722768');
INSERT INTO "public"."launcher_download_log" VALUES (477, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:41:00.761774');
INSERT INTO "public"."launcher_download_log" VALUES (478, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:44:25.646534');
INSERT INTO "public"."launcher_download_log" VALUES (479, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:44:25.6901');
INSERT INTO "public"."launcher_download_log" VALUES (480, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:47:50.637724');
INSERT INTO "public"."launcher_download_log" VALUES (481, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:47:50.705183');
INSERT INTO "public"."launcher_download_log" VALUES (482, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:53:37.395283');
INSERT INTO "public"."launcher_download_log" VALUES (483, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:53:44.998501');
INSERT INTO "public"."launcher_download_log" VALUES (485, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:53:55.88794');
INSERT INTO "public"."launcher_download_log" VALUES (487, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:56:40.227982');
INSERT INTO "public"."launcher_download_log" VALUES (488, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:57:38.633999');
INSERT INTO "public"."launcher_download_log" VALUES (489, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 17:57:39.443342');
INSERT INTO "public"."launcher_download_log" VALUES (491, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:00:11.25336');
INSERT INTO "public"."launcher_download_log" VALUES (494, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:06:11.035911');
INSERT INTO "public"."launcher_download_log" VALUES (495, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:06:11.082394');
INSERT INTO "public"."launcher_download_log" VALUES (1313, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:11.269854');
INSERT INTO "public"."launcher_download_log" VALUES (1316, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:45.646978');
INSERT INTO "public"."launcher_download_log" VALUES (1318, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:45.676344');
INSERT INTO "public"."launcher_download_log" VALUES (1319, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:47.688884');
INSERT INTO "public"."launcher_download_log" VALUES (1320, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:47.714227');
INSERT INTO "public"."launcher_download_log" VALUES (1321, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:15.681716');
INSERT INTO "public"."launcher_download_log" VALUES (1322, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:15.708789');
INSERT INTO "public"."launcher_download_log" VALUES (1323, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:15.760989');
INSERT INTO "public"."launcher_download_log" VALUES (1330, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:45.657264');
INSERT INTO "public"."launcher_download_log" VALUES (1341, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:09:45.779926');
INSERT INTO "public"."launcher_download_log" VALUES (1342, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:09:45.803805');
INSERT INTO "public"."launcher_download_log" VALUES (1343, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:09:47.760511');
INSERT INTO "public"."launcher_download_log" VALUES (1344, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:09:47.783458');
INSERT INTO "public"."launcher_download_log" VALUES (1346, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:15.662708');
INSERT INTO "public"."launcher_download_log" VALUES (1361, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:12:28.772151');
INSERT INTO "public"."launcher_download_log" VALUES (1370, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:33.141177');
INSERT INTO "public"."launcher_download_log" VALUES (1377, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:58.684893');
INSERT INTO "public"."launcher_download_log" VALUES (1378, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:58.707455');
INSERT INTO "public"."launcher_download_log" VALUES (1381, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:03.219158');
INSERT INTO "public"."launcher_download_log" VALUES (1389, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:35.121677');
INSERT INTO "public"."launcher_download_log" VALUES (1391, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:35.151725');
INSERT INTO "public"."launcher_download_log" VALUES (1396, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:03.197564');
INSERT INTO "public"."launcher_download_log" VALUES (1397, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:03.22164');
INSERT INTO "public"."launcher_download_log" VALUES (1401, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:33.113528');
INSERT INTO "public"."launcher_download_log" VALUES (1403, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:33.164464');
INSERT INTO "public"."launcher_download_log" VALUES (1405, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:35.134543');
INSERT INTO "public"."launcher_download_log" VALUES (1406, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:35.159706');
INSERT INTO "public"."launcher_download_log" VALUES (1414, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:43.383858');
INSERT INTO "public"."launcher_download_log" VALUES (1420, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:13.362514');
INSERT INTO "public"."launcher_download_log" VALUES (1425, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:43.404265');
INSERT INTO "public"."launcher_download_log" VALUES (1428, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:43.433087');
INSERT INTO "public"."launcher_download_log" VALUES (1432, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:15.424587');
INSERT INTO "public"."launcher_download_log" VALUES (1434, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:15.451306');
INSERT INTO "public"."launcher_download_log" VALUES (1435, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:17.427066');
INSERT INTO "public"."launcher_download_log" VALUES (1436, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:17.450946');
INSERT INTO "public"."launcher_download_log" VALUES (1440, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:43.398624');
INSERT INTO "public"."launcher_download_log" VALUES (1447, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:13.505316');
INSERT INTO "public"."launcher_download_log" VALUES (1656, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:14:47.543959');
INSERT INTO "public"."launcher_download_log" VALUES (1657, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:15:14.71712');
INSERT INTO "public"."launcher_download_log" VALUES (1879, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:18.483106');
INSERT INTO "public"."launcher_download_log" VALUES (1883, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:04:48.470793');
INSERT INTO "public"."launcher_download_log" VALUES (1891, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:05:20.544402');
INSERT INTO "public"."launcher_download_log" VALUES (1898, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:07:56.628029');
INSERT INTO "public"."launcher_download_log" VALUES (1902, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:08:31.087742');
INSERT INTO "public"."launcher_download_log" VALUES (1907, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:09:01.007282');
INSERT INTO "public"."launcher_download_log" VALUES (1913, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:13:46.009344');
INSERT INTO "public"."launcher_download_log" VALUES (1918, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:13:46.064136');
INSERT INTO "public"."launcher_download_log" VALUES (2074, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:14:43.169168');
INSERT INTO "public"."launcher_download_log" VALUES (2076, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:14:45.58112');
INSERT INTO "public"."launcher_download_log" VALUES (2078, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:17:38.34807');
INSERT INTO "public"."launcher_download_log" VALUES (2080, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:17:39.029289');
INSERT INTO "public"."launcher_download_log" VALUES (2082, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:17:39.474985');
INSERT INTO "public"."launcher_download_log" VALUES (2084, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:18:03.878778');
INSERT INTO "public"."launcher_download_log" VALUES (2086, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:22:15.310333');
INSERT INTO "public"."launcher_download_log" VALUES (2088, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:22:15.390682');
INSERT INTO "public"."launcher_download_log" VALUES (2090, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:22:15.636375');
INSERT INTO "public"."launcher_download_log" VALUES (2092, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:22:15.66785');
INSERT INTO "public"."launcher_download_log" VALUES (2097, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:23:42.638548');
INSERT INTO "public"."launcher_download_log" VALUES (2098, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:23:42.653626');
INSERT INTO "public"."launcher_download_log" VALUES (2099, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:23:42.671786');
INSERT INTO "public"."launcher_download_log" VALUES (2114, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:28:01.860781');
INSERT INTO "public"."launcher_download_log" VALUES (2115, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:28:01.879759');
INSERT INTO "public"."launcher_download_log" VALUES (2191, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:58:26.891721');
INSERT INTO "public"."launcher_download_log" VALUES (2193, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:59:01.163572');
INSERT INTO "public"."launcher_download_log" VALUES (2202, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:02:42.028619');
INSERT INTO "public"."launcher_download_log" VALUES (2204, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:02:42.21222');
INSERT INTO "public"."launcher_download_log" VALUES (2205, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:02:59.962335');
INSERT INTO "public"."launcher_download_log" VALUES (2206, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:03:00.237315');
INSERT INTO "public"."launcher_download_log" VALUES (2207, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:03:00.263323');
INSERT INTO "public"."launcher_download_log" VALUES (2209, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:03:00.484938');
INSERT INTO "public"."launcher_download_log" VALUES (2211, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:04:24.11992');
INSERT INTO "public"."launcher_download_log" VALUES (2214, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:04:24.388111');
INSERT INTO "public"."launcher_download_log" VALUES (2216, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:04:24.604748');
INSERT INTO "public"."launcher_download_log" VALUES (2219, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:04:59.048481');
INSERT INTO "public"."launcher_download_log" VALUES (2221, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:00.833952');
INSERT INTO "public"."launcher_download_log" VALUES (2223, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:28.778477');
INSERT INTO "public"."launcher_download_log" VALUES (2224, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:28.800326');
INSERT INTO "public"."launcher_download_log" VALUES (2226, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:29.048306');
INSERT INTO "public"."launcher_download_log" VALUES (2228, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:31.06188');
INSERT INTO "public"."launcher_download_log" VALUES (2229, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:58.786401');
INSERT INTO "public"."launcher_download_log" VALUES (2231, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:59.033747');
INSERT INTO "public"."launcher_download_log" VALUES (2233, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:00.878866');
INSERT INTO "public"."launcher_download_log" VALUES (2235, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:25.267474');
INSERT INTO "public"."launcher_download_log" VALUES (2236, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:25.477831');
INSERT INTO "public"."launcher_download_log" VALUES (2239, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:06:25.737489');
INSERT INTO "public"."launcher_download_log" VALUES (2240, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:06:25.737837');
INSERT INTO "public"."launcher_download_log" VALUES (2241, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:59.922555');
INSERT INTO "public"."launcher_download_log" VALUES (2242, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:59.941115');
INSERT INTO "public"."launcher_download_log" VALUES (2243, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:00.170052');
INSERT INTO "public"."launcher_download_log" VALUES (2244, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:00.186789');
INSERT INTO "public"."launcher_download_log" VALUES (2245, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:01.954688');
INSERT INTO "public"."launcher_download_log" VALUES (486, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 17:56:33.665335');
INSERT INTO "public"."launcher_download_log" VALUES (490, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:00:11.211363');
INSERT INTO "public"."launcher_download_log" VALUES (492, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:02:45.283952');
INSERT INTO "public"."launcher_download_log" VALUES (493, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:02:45.345582');
INSERT INTO "public"."launcher_download_log" VALUES (496, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:17:18.36619');
INSERT INTO "public"."launcher_download_log" VALUES (497, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:17:18.408517');
INSERT INTO "public"."launcher_download_log" VALUES (498, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:12.896571');
INSERT INTO "public"."launcher_download_log" VALUES (499, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:12.988332');
INSERT INTO "public"."launcher_download_log" VALUES (500, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:37.002925');
INSERT INTO "public"."launcher_download_log" VALUES (501, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:37.031424');
INSERT INTO "public"."launcher_download_log" VALUES (502, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:38.33234');
INSERT INTO "public"."launcher_download_log" VALUES (503, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:38.353261');
INSERT INTO "public"."launcher_download_log" VALUES (504, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:39.491275');
INSERT INTO "public"."launcher_download_log" VALUES (505, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:39.512511');
INSERT INTO "public"."launcher_download_log" VALUES (506, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:40.178775');
INSERT INTO "public"."launcher_download_log" VALUES (507, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:40.200021');
INSERT INTO "public"."launcher_download_log" VALUES (508, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:22:40.723779');
INSERT INTO "public"."launcher_download_log" VALUES (509, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:22:40.744142');
INSERT INTO "public"."launcher_download_log" VALUES (510, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:29:22.477331');
INSERT INTO "public"."launcher_download_log" VALUES (511, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:29:22.517263');
INSERT INTO "public"."launcher_download_log" VALUES (512, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:31:20.84363');
INSERT INTO "public"."launcher_download_log" VALUES (513, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:31:20.886745');
INSERT INTO "public"."launcher_download_log" VALUES (514, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:31:51.75891');
INSERT INTO "public"."launcher_download_log" VALUES (515, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:31:51.799559');
INSERT INTO "public"."launcher_download_log" VALUES (516, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:32:28.728873');
INSERT INTO "public"."launcher_download_log" VALUES (517, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:32:28.763646');
INSERT INTO "public"."launcher_download_log" VALUES (518, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:32:58.485478');
INSERT INTO "public"."launcher_download_log" VALUES (519, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:32:58.505981');
INSERT INTO "public"."launcher_download_log" VALUES (520, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:34:54.326687');
INSERT INTO "public"."launcher_download_log" VALUES (521, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:34:54.374307');
INSERT INTO "public"."launcher_download_log" VALUES (522, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:35:05.029456');
INSERT INTO "public"."launcher_download_log" VALUES (523, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:35:05.056586');
INSERT INTO "public"."launcher_download_log" VALUES (524, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:35:40.97732');
INSERT INTO "public"."launcher_download_log" VALUES (525, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:35:41.03599');
INSERT INTO "public"."launcher_download_log" VALUES (526, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:43:59.382018');
INSERT INTO "public"."launcher_download_log" VALUES (527, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:43:59.425534');
INSERT INTO "public"."launcher_download_log" VALUES (528, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:50:13.014061');
INSERT INTO "public"."launcher_download_log" VALUES (529, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:50:13.080436');
INSERT INTO "public"."launcher_download_log" VALUES (530, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:50:33.334045');
INSERT INTO "public"."launcher_download_log" VALUES (531, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:50:33.383224');
INSERT INTO "public"."launcher_download_log" VALUES (532, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:51:10.124229');
INSERT INTO "public"."launcher_download_log" VALUES (533, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:51:10.160256');
INSERT INTO "public"."launcher_download_log" VALUES (534, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:51:35.37861');
INSERT INTO "public"."launcher_download_log" VALUES (535, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:51:35.424916');
INSERT INTO "public"."launcher_download_log" VALUES (536, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:51:53.584001');
INSERT INTO "public"."launcher_download_log" VALUES (537, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:51:53.632951');
INSERT INTO "public"."launcher_download_log" VALUES (538, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:52:16.467217');
INSERT INTO "public"."launcher_download_log" VALUES (539, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:52:16.516211');
INSERT INTO "public"."launcher_download_log" VALUES (540, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:52:38.833676');
INSERT INTO "public"."launcher_download_log" VALUES (541, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:52:38.882359');
INSERT INTO "public"."launcher_download_log" VALUES (542, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:53:15.593263');
INSERT INTO "public"."launcher_download_log" VALUES (543, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:53:15.614016');
INSERT INTO "public"."launcher_download_log" VALUES (544, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:55:33.338275');
INSERT INTO "public"."launcher_download_log" VALUES (545, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:55:33.380095');
INSERT INTO "public"."launcher_download_log" VALUES (546, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:57:05.791894');
INSERT INTO "public"."launcher_download_log" VALUES (547, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:57:05.834273');
INSERT INTO "public"."launcher_download_log" VALUES (548, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:57:37.428369');
INSERT INTO "public"."launcher_download_log" VALUES (549, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:57:37.468889');
INSERT INTO "public"."launcher_download_log" VALUES (550, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:58:29.312226');
INSERT INTO "public"."launcher_download_log" VALUES (551, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:58:29.362039');
INSERT INTO "public"."launcher_download_log" VALUES (552, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:59:00.038442');
INSERT INTO "public"."launcher_download_log" VALUES (553, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:59:00.089185');
INSERT INTO "public"."launcher_download_log" VALUES (554, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 18:59:36.815911');
INSERT INTO "public"."launcher_download_log" VALUES (555, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 18:59:36.836861');
INSERT INTO "public"."launcher_download_log" VALUES (556, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:00:36.804069');
INSERT INTO "public"."launcher_download_log" VALUES (557, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:00:36.825131');
INSERT INTO "public"."launcher_download_log" VALUES (558, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:01:08.837947');
INSERT INTO "public"."launcher_download_log" VALUES (559, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:01:08.860277');
INSERT INTO "public"."launcher_download_log" VALUES (560, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:01:12.052675');
INSERT INTO "public"."launcher_download_log" VALUES (561, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:01:12.074681');
INSERT INTO "public"."launcher_download_log" VALUES (562, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:02:33.087356');
INSERT INTO "public"."launcher_download_log" VALUES (563, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:02:33.135227');
INSERT INTO "public"."launcher_download_log" VALUES (564, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:03:30.055984');
INSERT INTO "public"."launcher_download_log" VALUES (565, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:03:30.109592');
INSERT INTO "public"."launcher_download_log" VALUES (566, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:07:19.8346');
INSERT INTO "public"."launcher_download_log" VALUES (567, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:07:19.880325');
INSERT INTO "public"."launcher_download_log" VALUES (568, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:07:56.643117');
INSERT INTO "public"."launcher_download_log" VALUES (569, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:07:56.664598');
INSERT INTO "public"."launcher_download_log" VALUES (570, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:08:26.56045');
INSERT INTO "public"."launcher_download_log" VALUES (571, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:08:26.581058');
INSERT INTO "public"."launcher_download_log" VALUES (572, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:08:56.620057');
INSERT INTO "public"."launcher_download_log" VALUES (573, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:08:56.641157');
INSERT INTO "public"."launcher_download_log" VALUES (574, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:09:26.607819');
INSERT INTO "public"."launcher_download_log" VALUES (575, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:09:26.630516');
INSERT INTO "public"."launcher_download_log" VALUES (576, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:09:56.582222');
INSERT INTO "public"."launcher_download_log" VALUES (577, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:09:56.603598');
INSERT INTO "public"."launcher_download_log" VALUES (578, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:10:26.583259');
INSERT INTO "public"."launcher_download_log" VALUES (579, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:10:26.604716');
INSERT INTO "public"."launcher_download_log" VALUES (580, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:10:56.560514');
INSERT INTO "public"."launcher_download_log" VALUES (581, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:10:56.582254');
INSERT INTO "public"."launcher_download_log" VALUES (582, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:11:26.594136');
INSERT INTO "public"."launcher_download_log" VALUES (583, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:11:26.616078');
INSERT INTO "public"."launcher_download_log" VALUES (584, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:11:56.591297');
INSERT INTO "public"."launcher_download_log" VALUES (585, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:11:56.61584');
INSERT INTO "public"."launcher_download_log" VALUES (586, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:12:26.601277');
INSERT INTO "public"."launcher_download_log" VALUES (587, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:12:26.623424');
INSERT INTO "public"."launcher_download_log" VALUES (588, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:12:56.512722');
INSERT INTO "public"."launcher_download_log" VALUES (589, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:12:56.533809');
INSERT INTO "public"."launcher_download_log" VALUES (590, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:13:26.580623');
INSERT INTO "public"."launcher_download_log" VALUES (591, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:13:26.602098');
INSERT INTO "public"."launcher_download_log" VALUES (592, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:13:56.610498');
INSERT INTO "public"."launcher_download_log" VALUES (593, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:13:56.632584');
INSERT INTO "public"."launcher_download_log" VALUES (594, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:14:26.634269');
INSERT INTO "public"."launcher_download_log" VALUES (596, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:14:56.580961');
INSERT INTO "public"."launcher_download_log" VALUES (598, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:15:28.640831');
INSERT INTO "public"."launcher_download_log" VALUES (600, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:15:56.641379');
INSERT INTO "public"."launcher_download_log" VALUES (602, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:16:26.594347');
INSERT INTO "public"."launcher_download_log" VALUES (604, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:16:56.687728');
INSERT INTO "public"."launcher_download_log" VALUES (606, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:17:28.644771');
INSERT INTO "public"."launcher_download_log" VALUES (608, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:17:56.617021');
INSERT INTO "public"."launcher_download_log" VALUES (610, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:18:26.571029');
INSERT INTO "public"."launcher_download_log" VALUES (612, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:18:56.641578');
INSERT INTO "public"."launcher_download_log" VALUES (614, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:19:28.656361');
INSERT INTO "public"."launcher_download_log" VALUES (616, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:19:56.603207');
INSERT INTO "public"."launcher_download_log" VALUES (618, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:20:26.646193');
INSERT INTO "public"."launcher_download_log" VALUES (620, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:20:56.644766');
INSERT INTO "public"."launcher_download_log" VALUES (622, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:21:28.696779');
INSERT INTO "public"."launcher_download_log" VALUES (624, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:21:56.625549');
INSERT INTO "public"."launcher_download_log" VALUES (626, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:22:26.623372');
INSERT INTO "public"."launcher_download_log" VALUES (628, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:22:56.646892');
INSERT INTO "public"."launcher_download_log" VALUES (630, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:23:28.691372');
INSERT INTO "public"."launcher_download_log" VALUES (632, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:23:56.634967');
INSERT INTO "public"."launcher_download_log" VALUES (634, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:24:26.635416');
INSERT INTO "public"."launcher_download_log" VALUES (636, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:24:56.659885');
INSERT INTO "public"."launcher_download_log" VALUES (638, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:25:28.659907');
INSERT INTO "public"."launcher_download_log" VALUES (640, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:25:56.644382');
INSERT INTO "public"."launcher_download_log" VALUES (642, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:26:26.626158');
INSERT INTO "public"."launcher_download_log" VALUES (644, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:26:56.64609');
INSERT INTO "public"."launcher_download_log" VALUES (646, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:27:28.768568');
INSERT INTO "public"."launcher_download_log" VALUES (648, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:27:56.702594');
INSERT INTO "public"."launcher_download_log" VALUES (650, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:28:26.710381');
INSERT INTO "public"."launcher_download_log" VALUES (652, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:28:56.702854');
INSERT INTO "public"."launcher_download_log" VALUES (654, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:29:28.73564');
INSERT INTO "public"."launcher_download_log" VALUES (656, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:29:56.672629');
INSERT INTO "public"."launcher_download_log" VALUES (658, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:30:26.681873');
INSERT INTO "public"."launcher_download_log" VALUES (660, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:30:56.691488');
INSERT INTO "public"."launcher_download_log" VALUES (662, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:31:26.669547');
INSERT INTO "public"."launcher_download_log" VALUES (664, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:31:56.649506');
INSERT INTO "public"."launcher_download_log" VALUES (666, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:32:26.677504');
INSERT INTO "public"."launcher_download_log" VALUES (668, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:32:56.694627');
INSERT INTO "public"."launcher_download_log" VALUES (670, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:33:26.727677');
INSERT INTO "public"."launcher_download_log" VALUES (672, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:35:53.884251');
INSERT INTO "public"."launcher_download_log" VALUES (674, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:37:32.883209');
INSERT INTO "public"."launcher_download_log" VALUES (676, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:38:09.664159');
INSERT INTO "public"."launcher_download_log" VALUES (679, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:38:29.953705');
INSERT INTO "public"."launcher_download_log" VALUES (681, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:39:06.638132');
INSERT INTO "public"."launcher_download_log" VALUES (1315, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:07:45.627192');
INSERT INTO "public"."launcher_download_log" VALUES (1317, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:07:45.658285');
INSERT INTO "public"."launcher_download_log" VALUES (1324, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:15.766186');
INSERT INTO "public"."launcher_download_log" VALUES (1325, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:15.789442');
INSERT INTO "public"."launcher_download_log" VALUES (1326, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:17.741762');
INSERT INTO "public"."launcher_download_log" VALUES (1327, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:08:17.766485');
INSERT INTO "public"."launcher_download_log" VALUES (1328, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:08:45.617844');
INSERT INTO "public"."launcher_download_log" VALUES (1335, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:09:38.247972');
INSERT INTO "public"."launcher_download_log" VALUES (1336, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:09:38.280506');
INSERT INTO "public"."launcher_download_log" VALUES (1339, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:09:45.705112');
INSERT INTO "public"."launcher_download_log" VALUES (1345, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:15.641854');
INSERT INTO "public"."launcher_download_log" VALUES (1347, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:15.673264');
INSERT INTO "public"."launcher_download_log" VALUES (1348, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:15.692605');
INSERT INTO "public"."launcher_download_log" VALUES (1349, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:17.684923');
INSERT INTO "public"."launcher_download_log" VALUES (1350, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:17.708403');
INSERT INTO "public"."launcher_download_log" VALUES (1353, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:45.689552');
INSERT INTO "public"."launcher_download_log" VALUES (1354, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:45.708556');
INSERT INTO "public"."launcher_download_log" VALUES (1355, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:10:47.704576');
INSERT INTO "public"."launcher_download_log" VALUES (1356, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:10:47.727122');
INSERT INTO "public"."launcher_download_log" VALUES (1358, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:12:28.503661');
INSERT INTO "public"."launcher_download_log" VALUES (1364, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:03.138731');
INSERT INTO "public"."launcher_download_log" VALUES (1369, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:33.088406');
INSERT INTO "public"."launcher_download_log" VALUES (1371, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:33.143816');
INSERT INTO "public"."launcher_download_log" VALUES (1372, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:33.16805');
INSERT INTO "public"."launcher_download_log" VALUES (1373, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:35.134525');
INSERT INTO "public"."launcher_download_log" VALUES (1374, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:35.159011');
INSERT INTO "public"."launcher_download_log" VALUES (1375, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:13:48.723415');
INSERT INTO "public"."launcher_download_log" VALUES (1376, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:13:48.746543');
INSERT INTO "public"."launcher_download_log" VALUES (1382, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:03.240024');
INSERT INTO "public"."launcher_download_log" VALUES (1384, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:03.267946');
INSERT INTO "public"."launcher_download_log" VALUES (1385, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:05.235458');
INSERT INTO "public"."launcher_download_log" VALUES (1386, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:05.260709');
INSERT INTO "public"."launcher_download_log" VALUES (1387, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:21.677263');
INSERT INTO "public"."launcher_download_log" VALUES (1388, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:21.700879');
INSERT INTO "public"."launcher_download_log" VALUES (1390, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:35.139787');
INSERT INTO "public"."launcher_download_log" VALUES (1392, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:35.167368');
INSERT INTO "public"."launcher_download_log" VALUES (1393, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:14:37.163058');
INSERT INTO "public"."launcher_download_log" VALUES (1394, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:14:37.185294');
INSERT INTO "public"."launcher_download_log" VALUES (1402, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:15:33.113965');
INSERT INTO "public"."launcher_download_log" VALUES (1404, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:15:33.165461');
INSERT INTO "public"."launcher_download_log" VALUES (1407, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:08.708523');
INSERT INTO "public"."launcher_download_log" VALUES (1409, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:08.987553');
INSERT INTO "public"."launcher_download_log" VALUES (1412, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:09.026755');
INSERT INTO "public"."launcher_download_log" VALUES (1415, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:43.387434');
INSERT INTO "public"."launcher_download_log" VALUES (1416, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:43.409072');
INSERT INTO "public"."launcher_download_log" VALUES (1417, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:16:45.411153');
INSERT INTO "public"."launcher_download_log" VALUES (1418, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:16:45.436327');
INSERT INTO "public"."launcher_download_log" VALUES (1419, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:13.338356');
INSERT INTO "public"."launcher_download_log" VALUES (1426, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:43.407092');
INSERT INTO "public"."launcher_download_log" VALUES (1427, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:43.431105');
INSERT INTO "public"."launcher_download_log" VALUES (1429, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:17:45.445205');
INSERT INTO "public"."launcher_download_log" VALUES (1430, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:17:45.468948');
INSERT INTO "public"."launcher_download_log" VALUES (1431, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:15.39152');
INSERT INTO "public"."launcher_download_log" VALUES (1437, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:23.482462');
INSERT INTO "public"."launcher_download_log" VALUES (1438, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:23.511017');
INSERT INTO "public"."launcher_download_log" VALUES (1441, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:43.402692');
INSERT INTO "public"."launcher_download_log" VALUES (595, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:14:26.654984');
INSERT INTO "public"."launcher_download_log" VALUES (597, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:14:56.602108');
INSERT INTO "public"."launcher_download_log" VALUES (599, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:15:28.662589');
INSERT INTO "public"."launcher_download_log" VALUES (601, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:15:56.662587');
INSERT INTO "public"."launcher_download_log" VALUES (603, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:16:26.614463');
INSERT INTO "public"."launcher_download_log" VALUES (605, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:16:56.710378');
INSERT INTO "public"."launcher_download_log" VALUES (607, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:17:28.665661');
INSERT INTO "public"."launcher_download_log" VALUES (609, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:17:56.639248');
INSERT INTO "public"."launcher_download_log" VALUES (611, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:18:26.59124');
INSERT INTO "public"."launcher_download_log" VALUES (613, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:18:56.663992');
INSERT INTO "public"."launcher_download_log" VALUES (615, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:19:28.677154');
INSERT INTO "public"."launcher_download_log" VALUES (617, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:19:56.737304');
INSERT INTO "public"."launcher_download_log" VALUES (619, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:20:26.667527');
INSERT INTO "public"."launcher_download_log" VALUES (621, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:20:56.668574');
INSERT INTO "public"."launcher_download_log" VALUES (623, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:21:28.720695');
INSERT INTO "public"."launcher_download_log" VALUES (625, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:21:56.650564');
INSERT INTO "public"."launcher_download_log" VALUES (627, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:22:26.64373');
INSERT INTO "public"."launcher_download_log" VALUES (629, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:22:56.667585');
INSERT INTO "public"."launcher_download_log" VALUES (631, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:23:28.71123');
INSERT INTO "public"."launcher_download_log" VALUES (633, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:23:56.659357');
INSERT INTO "public"."launcher_download_log" VALUES (635, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:24:26.655752');
INSERT INTO "public"."launcher_download_log" VALUES (637, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:24:56.680647');
INSERT INTO "public"."launcher_download_log" VALUES (639, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:25:28.680307');
INSERT INTO "public"."launcher_download_log" VALUES (641, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:25:56.665462');
INSERT INTO "public"."launcher_download_log" VALUES (643, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:26:26.648251');
INSERT INTO "public"."launcher_download_log" VALUES (645, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:26:56.667029');
INSERT INTO "public"."launcher_download_log" VALUES (647, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:27:28.788686');
INSERT INTO "public"."launcher_download_log" VALUES (649, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:27:56.723984');
INSERT INTO "public"."launcher_download_log" VALUES (651, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:28:26.730348');
INSERT INTO "public"."launcher_download_log" VALUES (653, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:28:56.723814');
INSERT INTO "public"."launcher_download_log" VALUES (655, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:29:28.756074');
INSERT INTO "public"."launcher_download_log" VALUES (657, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:29:56.694128');
INSERT INTO "public"."launcher_download_log" VALUES (659, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:30:26.701988');
INSERT INTO "public"."launcher_download_log" VALUES (661, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:30:56.712675');
INSERT INTO "public"."launcher_download_log" VALUES (663, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:31:26.689522');
INSERT INTO "public"."launcher_download_log" VALUES (665, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:31:56.670337');
INSERT INTO "public"."launcher_download_log" VALUES (667, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:32:26.698733');
INSERT INTO "public"."launcher_download_log" VALUES (669, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:32:56.715699');
INSERT INTO "public"."launcher_download_log" VALUES (671, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:33:26.747492');
INSERT INTO "public"."launcher_download_log" VALUES (673, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:35:53.928668');
INSERT INTO "public"."launcher_download_log" VALUES (675, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:37:32.933168');
INSERT INTO "public"."launcher_download_log" VALUES (677, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:38:09.68609');
INSERT INTO "public"."launcher_download_log" VALUES (678, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:38:29.906941');
INSERT INTO "public"."launcher_download_log" VALUES (680, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:39:06.615553');
INSERT INTO "public"."launcher_download_log" VALUES (682, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:39:36.702358');
INSERT INTO "public"."launcher_download_log" VALUES (683, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:39:36.727264');
INSERT INTO "public"."launcher_download_log" VALUES (684, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:40:06.596441');
INSERT INTO "public"."launcher_download_log" VALUES (685, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:40:06.618172');
INSERT INTO "public"."launcher_download_log" VALUES (686, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:40:38.653215');
INSERT INTO "public"."launcher_download_log" VALUES (687, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:40:38.678436');
INSERT INTO "public"."launcher_download_log" VALUES (688, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:40:59.017546');
INSERT INTO "public"."launcher_download_log" VALUES (689, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:40:59.065336');
INSERT INTO "public"."launcher_download_log" VALUES (690, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:41:41.535682');
INSERT INTO "public"."launcher_download_log" VALUES (691, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:41:41.578626');
INSERT INTO "public"."launcher_download_log" VALUES (692, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:42:18.397821');
INSERT INTO "public"."launcher_download_log" VALUES (693, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:42:18.418644');
INSERT INTO "public"."launcher_download_log" VALUES (694, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:42:48.352398');
INSERT INTO "public"."launcher_download_log" VALUES (695, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:42:48.375305');
INSERT INTO "public"."launcher_download_log" VALUES (696, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:43:14.440668');
INSERT INTO "public"."launcher_download_log" VALUES (697, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:43:14.563213');
INSERT INTO "public"."launcher_download_log" VALUES (698, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:44:08.698874');
INSERT INTO "public"."launcher_download_log" VALUES (699, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:44:08.742293');
INSERT INTO "public"."launcher_download_log" VALUES (700, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:44:38.012909');
INSERT INTO "public"."launcher_download_log" VALUES (701, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:44:38.056476');
INSERT INTO "public"."launcher_download_log" VALUES (702, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:44:55.822304');
INSERT INTO "public"."launcher_download_log" VALUES (703, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:44:55.868076');
INSERT INTO "public"."launcher_download_log" VALUES (704, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:45:32.624257');
INSERT INTO "public"."launcher_download_log" VALUES (705, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:45:32.645825');
INSERT INTO "public"."launcher_download_log" VALUES (706, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:46:02.707503');
INSERT INTO "public"."launcher_download_log" VALUES (707, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:46:02.728379');
INSERT INTO "public"."launcher_download_log" VALUES (708, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:46:32.603626');
INSERT INTO "public"."launcher_download_log" VALUES (709, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:46:32.625692');
INSERT INTO "public"."launcher_download_log" VALUES (710, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:47:03.562502');
INSERT INTO "public"."launcher_download_log" VALUES (711, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:47:03.60469');
INSERT INTO "public"."launcher_download_log" VALUES (712, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:47:40.31615');
INSERT INTO "public"."launcher_download_log" VALUES (713, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:47:40.33778');
INSERT INTO "public"."launcher_download_log" VALUES (714, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:48:10.327559');
INSERT INTO "public"."launcher_download_log" VALUES (715, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:48:10.352857');
INSERT INTO "public"."launcher_download_log" VALUES (716, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:48:40.336052');
INSERT INTO "public"."launcher_download_log" VALUES (717, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:48:40.3636');
INSERT INTO "public"."launcher_download_log" VALUES (718, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:49:12.407308');
INSERT INTO "public"."launcher_download_log" VALUES (719, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:49:12.42975');
INSERT INTO "public"."launcher_download_log" VALUES (720, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:49:29.845278');
INSERT INTO "public"."launcher_download_log" VALUES (721, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:49:29.95176');
INSERT INTO "public"."launcher_download_log" VALUES (722, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:50:09.983915');
INSERT INTO "public"."launcher_download_log" VALUES (723, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:50:10.037581');
INSERT INTO "public"."launcher_download_log" VALUES (724, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:50:24.869177');
INSERT INTO "public"."launcher_download_log" VALUES (725, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:50:24.911645');
INSERT INTO "public"."launcher_download_log" VALUES (726, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:51:01.674638');
INSERT INTO "public"."launcher_download_log" VALUES (727, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:51:01.697279');
INSERT INTO "public"."launcher_download_log" VALUES (728, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:51:31.724043');
INSERT INTO "public"."launcher_download_log" VALUES (729, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:51:31.745818');
INSERT INTO "public"."launcher_download_log" VALUES (730, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:52:01.625832');
INSERT INTO "public"."launcher_download_log" VALUES (731, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:52:01.648892');
INSERT INTO "public"."launcher_download_log" VALUES (732, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:52:20.848153');
INSERT INTO "public"."launcher_download_log" VALUES (733, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:52:20.888737');
INSERT INTO "public"."launcher_download_log" VALUES (734, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:52:57.591865');
INSERT INTO "public"."launcher_download_log" VALUES (735, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:52:57.615543');
INSERT INTO "public"."launcher_download_log" VALUES (736, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:53:27.585662');
INSERT INTO "public"."launcher_download_log" VALUES (737, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:53:27.608506');
INSERT INTO "public"."launcher_download_log" VALUES (738, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:53:57.531279');
INSERT INTO "public"."launcher_download_log" VALUES (739, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:53:57.554536');
INSERT INTO "public"."launcher_download_log" VALUES (740, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:54:29.579681');
INSERT INTO "public"."launcher_download_log" VALUES (741, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:54:29.602041');
INSERT INTO "public"."launcher_download_log" VALUES (742, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:54:57.525655');
INSERT INTO "public"."launcher_download_log" VALUES (744, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:55:28.495046');
INSERT INTO "public"."launcher_download_log" VALUES (746, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:55:58.46311');
INSERT INTO "public"."launcher_download_log" VALUES (748, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:56:27.59178');
INSERT INTO "public"."launcher_download_log" VALUES (751, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:56:43.169835');
INSERT INTO "public"."launcher_download_log" VALUES (752, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:56:59.44749');
INSERT INTO "public"."launcher_download_log" VALUES (754, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:57:46.827586');
INSERT INTO "public"."launcher_download_log" VALUES (755, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:57:46.87533');
INSERT INTO "public"."launcher_download_log" VALUES (757, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:58:34.847144');
INSERT INTO "public"."launcher_download_log" VALUES (759, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:59:11.616549');
INSERT INTO "public"."launcher_download_log" VALUES (760, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:59:20.705831');
INSERT INTO "public"."launcher_download_log" VALUES (761, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:59:20.747852');
INSERT INTO "public"."launcher_download_log" VALUES (763, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:59:57.4914');
INSERT INTO "public"."launcher_download_log" VALUES (765, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:00:27.461119');
INSERT INTO "public"."launcher_download_log" VALUES (767, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:01:02.481623');
INSERT INTO "public"."launcher_download_log" VALUES (770, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:02:18.638372');
INSERT INTO "public"."launcher_download_log" VALUES (771, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:02:18.686308');
INSERT INTO "public"."launcher_download_log" VALUES (773, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:04:02.287747');
INSERT INTO "public"."launcher_download_log" VALUES (775, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:04:38.977819');
INSERT INTO "public"."launcher_download_log" VALUES (777, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:05:03.788253');
INSERT INTO "public"."launcher_download_log" VALUES (781, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:06:15.306797');
INSERT INTO "public"."launcher_download_log" VALUES (783, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:06:51.999369');
INSERT INTO "public"."launcher_download_log" VALUES (785, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:07:22.026259');
INSERT INTO "public"."launcher_download_log" VALUES (787, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:07:52.039182');
INSERT INTO "public"."launcher_download_log" VALUES (789, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:08:24.037873');
INSERT INTO "public"."launcher_download_log" VALUES (791, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:08:52.009412');
INSERT INTO "public"."launcher_download_log" VALUES (793, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:09:21.982671');
INSERT INTO "public"."launcher_download_log" VALUES (797, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:10:19.632597');
INSERT INTO "public"."launcher_download_log" VALUES (800, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:13:02.592747');
INSERT INTO "public"."launcher_download_log" VALUES (801, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:13:02.63918');
INSERT INTO "public"."launcher_download_log" VALUES (1442, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:43.424929');
INSERT INTO "public"."launcher_download_log" VALUES (1443, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:18:45.407332');
INSERT INTO "public"."launcher_download_log" VALUES (1444, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:18:45.430872');
INSERT INTO "public"."launcher_download_log" VALUES (1445, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:13.438811');
INSERT INTO "public"."launcher_download_log" VALUES (1448, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:13.53129');
INSERT INTO "public"."launcher_download_log" VALUES (1449, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:15.496376');
INSERT INTO "public"."launcher_download_log" VALUES (1450, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:15.521947');
INSERT INTO "public"."launcher_download_log" VALUES (1452, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:43.372325');
INSERT INTO "public"."launcher_download_log" VALUES (1453, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:43.398011');
INSERT INTO "public"."launcher_download_log" VALUES (1455, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:19:45.422199');
INSERT INTO "public"."launcher_download_log" VALUES (1456, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:19:45.446121');
INSERT INTO "public"."launcher_download_log" VALUES (1659, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:16:41.305941');
INSERT INTO "public"."launcher_download_log" VALUES (1660, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:16:41.346946');
INSERT INTO "public"."launcher_download_log" VALUES (1661, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:16:41.716781');
INSERT INTO "public"."launcher_download_log" VALUES (1662, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:16:41.751184');
INSERT INTO "public"."launcher_download_log" VALUES (1663, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:16:41.879708');
INSERT INTO "public"."launcher_download_log" VALUES (1664, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:16:41.911995');
INSERT INTO "public"."launcher_download_log" VALUES (1665, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:16:43.292266');
INSERT INTO "public"."launcher_download_log" VALUES (1666, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:16:43.319763');
INSERT INTO "public"."launcher_download_log" VALUES (1667, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:16:44.100204');
INSERT INTO "public"."launcher_download_log" VALUES (1669, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:17:14.690632');
INSERT INTO "public"."launcher_download_log" VALUES (1672, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:17:15.127946');
INSERT INTO "public"."launcher_download_log" VALUES (1674, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:17:57.827226');
INSERT INTO "public"."launcher_download_log" VALUES (1888, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:04:50.555755');
INSERT INTO "public"."launcher_download_log" VALUES (1889, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:05:20.500433');
INSERT INTO "public"."launcher_download_log" VALUES (1895, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:07:56.383904');
INSERT INTO "public"."launcher_download_log" VALUES (1897, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:07:56.622412');
INSERT INTO "public"."launcher_download_log" VALUES (1899, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:07:56.660964');
INSERT INTO "public"."launcher_download_log" VALUES (1903, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:08:31.092917');
INSERT INTO "public"."launcher_download_log" VALUES (1904, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:08:31.115903');
INSERT INTO "public"."launcher_download_log" VALUES (1905, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:08:33.111557');
INSERT INTO "public"."launcher_download_log" VALUES (1906, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:08:33.135597');
INSERT INTO "public"."launcher_download_log" VALUES (1909, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:09:01.059406');
INSERT INTO "public"."launcher_download_log" VALUES (1915, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:13:46.012607');
INSERT INTO "public"."launcher_download_log" VALUES (1916, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:13:46.063438');
INSERT INTO "public"."launcher_download_log" VALUES (1919, '127.0.0.1', '', 'Nuevo_documento_de_texto.txt', 'game_file', 't', '2025-06-05 00:13:46.126108');
INSERT INTO "public"."launcher_download_log" VALUES (2100, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:25:01.594856');
INSERT INTO "public"."launcher_download_log" VALUES (2101, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:25:01.678048');
INSERT INTO "public"."launcher_download_log" VALUES (2103, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:25:01.775349');
INSERT INTO "public"."launcher_download_log" VALUES (2105, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:25:01.823376');
INSERT INTO "public"."launcher_download_log" VALUES (2109, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:25:01.904108');
INSERT INTO "public"."launcher_download_log" VALUES (2110, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:25:01.938753');
INSERT INTO "public"."launcher_download_log" VALUES (2116, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:29:00.274837');
INSERT INTO "public"."launcher_download_log" VALUES (2122, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:29:13.881701');
INSERT INTO "public"."launcher_download_log" VALUES (2125, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:30:18.277178');
INSERT INTO "public"."launcher_download_log" VALUES (2126, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:18.337225');
INSERT INTO "public"."launcher_download_log" VALUES (2128, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:18.376861');
INSERT INTO "public"."launcher_download_log" VALUES (2130, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:34.840232');
INSERT INTO "public"."launcher_download_log" VALUES (2131, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:34.887511');
INSERT INTO "public"."launcher_download_log" VALUES (2134, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:35.012149');
INSERT INTO "public"."launcher_download_log" VALUES (2136, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:35.0452');
INSERT INTO "public"."launcher_download_log" VALUES (2141, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:31:09.546269');
INSERT INTO "public"."launcher_download_log" VALUES (2146, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:21.156642');
INSERT INTO "public"."launcher_download_log" VALUES (2148, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:21.220307');
INSERT INTO "public"."launcher_download_log" VALUES (2149, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:21.404936');
INSERT INTO "public"."launcher_download_log" VALUES (2150, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:21.436516');
INSERT INTO "public"."launcher_download_log" VALUES (2154, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:34.974004');
INSERT INTO "public"."launcher_download_log" VALUES (2164, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:42.168783');
INSERT INTO "public"."launcher_download_log" VALUES (2165, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:42.384812');
INSERT INTO "public"."launcher_download_log" VALUES (2166, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:42.431121');
INSERT INTO "public"."launcher_download_log" VALUES (2167, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:44.168803');
INSERT INTO "public"."launcher_download_log" VALUES (2168, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:46:44.414689');
INSERT INTO "public"."launcher_download_log" VALUES (2174, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:17.35279');
INSERT INTO "public"."launcher_download_log" VALUES (2181, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:51:21.521057');
INSERT INTO "public"."launcher_download_log" VALUES (2194, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:59:01.182125');
INSERT INTO "public"."launcher_download_log" VALUES (2195, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:59:01.406765');
INSERT INTO "public"."launcher_download_log" VALUES (2196, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:59:01.423567');
INSERT INTO "public"."launcher_download_log" VALUES (2197, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:59:03.190148');
INSERT INTO "public"."launcher_download_log" VALUES (2198, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:59:03.436173');
INSERT INTO "public"."launcher_download_log" VALUES (2199, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:02:41.747908');
INSERT INTO "public"."launcher_download_log" VALUES (743, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:54:57.54696');
INSERT INTO "public"."launcher_download_log" VALUES (745, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:55:28.520607');
INSERT INTO "public"."launcher_download_log" VALUES (747, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:55:58.487905');
INSERT INTO "public"."launcher_download_log" VALUES (749, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:56:27.613788');
INSERT INTO "public"."launcher_download_log" VALUES (750, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:56:43.11718');
INSERT INTO "public"."launcher_download_log" VALUES (753, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 19:56:59.487436');
INSERT INTO "public"."launcher_download_log" VALUES (756, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:58:34.800613');
INSERT INTO "public"."launcher_download_log" VALUES (758, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:59:11.593727');
INSERT INTO "public"."launcher_download_log" VALUES (762, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 19:59:57.469672');
INSERT INTO "public"."launcher_download_log" VALUES (764, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:00:27.440111');
INSERT INTO "public"."launcher_download_log" VALUES (766, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:01:02.423992');
INSERT INTO "public"."launcher_download_log" VALUES (768, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:02:03.611345');
INSERT INTO "public"."launcher_download_log" VALUES (769, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:02:03.665729');
INSERT INTO "public"."launcher_download_log" VALUES (772, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:04:02.24323');
INSERT INTO "public"."launcher_download_log" VALUES (774, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:04:38.954275');
INSERT INTO "public"."launcher_download_log" VALUES (776, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:05:03.738686');
INSERT INTO "public"."launcher_download_log" VALUES (778, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:05:44.04159');
INSERT INTO "public"."launcher_download_log" VALUES (779, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:05:44.085406');
INSERT INTO "public"."launcher_download_log" VALUES (780, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:06:15.26191');
INSERT INTO "public"."launcher_download_log" VALUES (782, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:06:51.977437');
INSERT INTO "public"."launcher_download_log" VALUES (784, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:07:22.004772');
INSERT INTO "public"."launcher_download_log" VALUES (786, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:07:52.018004');
INSERT INTO "public"."launcher_download_log" VALUES (788, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:08:24.016173');
INSERT INTO "public"."launcher_download_log" VALUES (790, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:08:51.987428');
INSERT INTO "public"."launcher_download_log" VALUES (792, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:09:21.956939');
INSERT INTO "public"."launcher_download_log" VALUES (794, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:09:42.155338');
INSERT INTO "public"."launcher_download_log" VALUES (795, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:09:42.201528');
INSERT INTO "public"."launcher_download_log" VALUES (796, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:10:19.586623');
INSERT INTO "public"."launcher_download_log" VALUES (798, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:12:37.680602');
INSERT INTO "public"."launcher_download_log" VALUES (799, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:12:37.723493');
INSERT INTO "public"."launcher_download_log" VALUES (802, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:13:39.367309');
INSERT INTO "public"."launcher_download_log" VALUES (803, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:13:39.389364');
INSERT INTO "public"."launcher_download_log" VALUES (804, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:14:09.34427');
INSERT INTO "public"."launcher_download_log" VALUES (805, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:14:09.367281');
INSERT INTO "public"."launcher_download_log" VALUES (806, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:14:39.392599');
INSERT INTO "public"."launcher_download_log" VALUES (807, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:14:39.417542');
INSERT INTO "public"."launcher_download_log" VALUES (808, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:15:11.33236');
INSERT INTO "public"."launcher_download_log" VALUES (809, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:15:11.353321');
INSERT INTO "public"."launcher_download_log" VALUES (810, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:15:39.326433');
INSERT INTO "public"."launcher_download_log" VALUES (811, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:15:39.34843');
INSERT INTO "public"."launcher_download_log" VALUES (812, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:16:09.386788');
INSERT INTO "public"."launcher_download_log" VALUES (813, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:16:09.409587');
INSERT INTO "public"."launcher_download_log" VALUES (814, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:16:33.750609');
INSERT INTO "public"."launcher_download_log" VALUES (815, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:16:33.801731');
INSERT INTO "public"."launcher_download_log" VALUES (816, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:17:10.549564');
INSERT INTO "public"."launcher_download_log" VALUES (817, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:17:10.57342');
INSERT INTO "public"."launcher_download_log" VALUES (818, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:17:40.463448');
INSERT INTO "public"."launcher_download_log" VALUES (819, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:17:40.485128');
INSERT INTO "public"."launcher_download_log" VALUES (820, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:18:10.506958');
INSERT INTO "public"."launcher_download_log" VALUES (821, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:18:10.528311');
INSERT INTO "public"."launcher_download_log" VALUES (822, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:18:42.514187');
INSERT INTO "public"."launcher_download_log" VALUES (823, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:18:42.536736');
INSERT INTO "public"."launcher_download_log" VALUES (824, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:18:58.688917');
INSERT INTO "public"."launcher_download_log" VALUES (825, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:18:58.73709');
INSERT INTO "public"."launcher_download_log" VALUES (826, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:19:35.39229');
INSERT INTO "public"."launcher_download_log" VALUES (827, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:19:35.414777');
INSERT INTO "public"."launcher_download_log" VALUES (828, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:20:05.454857');
INSERT INTO "public"."launcher_download_log" VALUES (829, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:20:05.478346');
INSERT INTO "public"."launcher_download_log" VALUES (830, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:31:52.150849');
INSERT INTO "public"."launcher_download_log" VALUES (831, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:31:52.194321');
INSERT INTO "public"."launcher_download_log" VALUES (832, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:22.256615');
INSERT INTO "public"."launcher_download_log" VALUES (833, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:22.299286');
INSERT INTO "public"."launcher_download_log" VALUES (834, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:22.576755');
INSERT INTO "public"."launcher_download_log" VALUES (835, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:22.577193');
INSERT INTO "public"."launcher_download_log" VALUES (836, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:22.660304');
INSERT INTO "public"."launcher_download_log" VALUES (837, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:22.660798');
INSERT INTO "public"."launcher_download_log" VALUES (838, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:56.990928');
INSERT INTO "public"."launcher_download_log" VALUES (839, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:57.007414');
INSERT INTO "public"."launcher_download_log" VALUES (840, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:57.031673');
INSERT INTO "public"."launcher_download_log" VALUES (841, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:57.041724');
INSERT INTO "public"."launcher_download_log" VALUES (842, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:34:58.999448');
INSERT INTO "public"."launcher_download_log" VALUES (843, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:34:59.021683');
INSERT INTO "public"."launcher_download_log" VALUES (844, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:26.960696');
INSERT INTO "public"."launcher_download_log" VALUES (845, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:27.014552');
INSERT INTO "public"."launcher_download_log" VALUES (846, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:27.050454');
INSERT INTO "public"."launcher_download_log" VALUES (847, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:27.084985');
INSERT INTO "public"."launcher_download_log" VALUES (848, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:29.047903');
INSERT INTO "public"."launcher_download_log" VALUES (849, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:29.071364');
INSERT INTO "public"."launcher_download_log" VALUES (850, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:57.274723');
INSERT INTO "public"."launcher_download_log" VALUES (851, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:57.28078');
INSERT INTO "public"."launcher_download_log" VALUES (852, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:57.333172');
INSERT INTO "public"."launcher_download_log" VALUES (853, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:57.337188');
INSERT INTO "public"."launcher_download_log" VALUES (854, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:35:59.298387');
INSERT INTO "public"."launcher_download_log" VALUES (855, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:35:59.321079');
INSERT INTO "public"."launcher_download_log" VALUES (856, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:29.002109');
INSERT INTO "public"."launcher_download_log" VALUES (857, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:29.075352');
INSERT INTO "public"."launcher_download_log" VALUES (858, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:29.082496');
INSERT INTO "public"."launcher_download_log" VALUES (859, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:29.104868');
INSERT INTO "public"."launcher_download_log" VALUES (860, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:31.224251');
INSERT INTO "public"."launcher_download_log" VALUES (861, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:31.245554');
INSERT INTO "public"."launcher_download_log" VALUES (862, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:56.88741');
INSERT INTO "public"."launcher_download_log" VALUES (863, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:56.93101');
INSERT INTO "public"."launcher_download_log" VALUES (864, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:56.935256');
INSERT INTO "public"."launcher_download_log" VALUES (865, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:56.963736');
INSERT INTO "public"."launcher_download_log" VALUES (866, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:36:58.930815');
INSERT INTO "public"."launcher_download_log" VALUES (867, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:36:58.953008');
INSERT INTO "public"."launcher_download_log" VALUES (868, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:37:14.537579');
INSERT INTO "public"."launcher_download_log" VALUES (869, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:37:14.579636');
INSERT INTO "public"."launcher_download_log" VALUES (870, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:37:14.715152');
INSERT INTO "public"."launcher_download_log" VALUES (871, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:37:14.71712');
INSERT INTO "public"."launcher_download_log" VALUES (872, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:37:14.748144');
INSERT INTO "public"."launcher_download_log" VALUES (873, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:37:14.748497');
INSERT INTO "public"."launcher_download_log" VALUES (874, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:38:24.734807');
INSERT INTO "public"."launcher_download_log" VALUES (876, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:38:25.028823');
INSERT INTO "public"."launcher_download_log" VALUES (878, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:38:25.129191');
INSERT INTO "public"."launcher_download_log" VALUES (880, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:38:59.481638');
INSERT INTO "public"."launcher_download_log" VALUES (883, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:38:59.558892');
INSERT INTO "public"."launcher_download_log" VALUES (885, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:01.583864');
INSERT INTO "public"."launcher_download_log" VALUES (1457, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:15.396755');
INSERT INTO "public"."launcher_download_log" VALUES (1464, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:43.383324');
INSERT INTO "public"."launcher_download_log" VALUES (1668, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:16:44.136898');
INSERT INTO "public"."launcher_download_log" VALUES (1670, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:17:14.722059');
INSERT INTO "public"."launcher_download_log" VALUES (1671, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:17:15.096528');
INSERT INTO "public"."launcher_download_log" VALUES (1673, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:17:22.075963');
INSERT INTO "public"."launcher_download_log" VALUES (1920, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:18:22.628663');
INSERT INTO "public"."launcher_download_log" VALUES (1921, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:18:22.714456');
INSERT INTO "public"."launcher_download_log" VALUES (1922, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:18:22.950574');
INSERT INTO "public"."launcher_download_log" VALUES (1925, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:18:22.985468');
INSERT INTO "public"."launcher_download_log" VALUES (1929, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:19:26.062038');
INSERT INTO "public"."launcher_download_log" VALUES (1930, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:19:26.131552');
INSERT INTO "public"."launcher_download_log" VALUES (1932, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:00.519336');
INSERT INTO "public"."launcher_download_log" VALUES (1933, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:00.56931');
INSERT INTO "public"."launcher_download_log" VALUES (1936, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:02.570983');
INSERT INTO "public"."launcher_download_log" VALUES (1939, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:30.508583');
INSERT INTO "public"."launcher_download_log" VALUES (1942, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:32.509933');
INSERT INTO "public"."launcher_download_log" VALUES (1945, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:45.762641');
INSERT INTO "public"."launcher_download_log" VALUES (1947, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:45.834535');
INSERT INTO "public"."launcher_download_log" VALUES (1948, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:45.871281');
INSERT INTO "public"."launcher_download_log" VALUES (1950, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:25.79151');
INSERT INTO "public"."launcher_download_log" VALUES (1953, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:25.989527');
INSERT INTO "public"."launcher_download_log" VALUES (1954, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:26.077148');
INSERT INTO "public"."launcher_download_log" VALUES (1956, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:47.333895');
INSERT INTO "public"."launcher_download_log" VALUES (1957, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:47.389719');
INSERT INTO "public"."launcher_download_log" VALUES (1958, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:47.607806');
INSERT INTO "public"."launcher_download_log" VALUES (1960, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:47.666181');
INSERT INTO "public"."launcher_download_log" VALUES (1962, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:03.606576');
INSERT INTO "public"."launcher_download_log" VALUES (1963, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:03.629873');
INSERT INTO "public"."launcher_download_log" VALUES (1966, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:22.007893');
INSERT INTO "public"."launcher_download_log" VALUES (1987, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:32:37.61186');
INSERT INTO "public"."launcher_download_log" VALUES (1991, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:32:37.86985');
INSERT INTO "public"."launcher_download_log" VALUES (1992, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:32:37.94329');
INSERT INTO "public"."launcher_download_log" VALUES (1998, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:12.25783');
INSERT INTO "public"."launcher_download_log" VALUES (2000, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:12.287487');
INSERT INTO "public"."launcher_download_log" VALUES (2002, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:14.26845');
INSERT INTO "public"."launcher_download_log" VALUES (2003, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:14.293824');
INSERT INTO "public"."launcher_download_log" VALUES (2005, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:42.293071');
INSERT INTO "public"."launcher_download_log" VALUES (2007, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:42.322427');
INSERT INTO "public"."launcher_download_log" VALUES (2008, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 00:33:42.336259');
INSERT INTO "public"."launcher_download_log" VALUES (2009, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:44.306697');
INSERT INTO "public"."launcher_download_log" VALUES (2010, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:44.337412');
INSERT INTO "public"."launcher_download_log" VALUES (2102, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:25:01.771639');
INSERT INTO "public"."launcher_download_log" VALUES (2104, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:25:01.792308');
INSERT INTO "public"."launcher_download_log" VALUES (2107, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:25:01.865383');
INSERT INTO "public"."launcher_download_log" VALUES (2108, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:25:01.882414');
INSERT INTO "public"."launcher_download_log" VALUES (2111, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 'f', '2025-06-05 02:25:01.94808');
INSERT INTO "public"."launcher_download_log" VALUES (2117, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:29:13.647199');
INSERT INTO "public"."launcher_download_log" VALUES (2118, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:29:13.732537');
INSERT INTO "public"."launcher_download_log" VALUES (2119, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:29:13.766485');
INSERT INTO "public"."launcher_download_log" VALUES (2120, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:29:13.813232');
INSERT INTO "public"."launcher_download_log" VALUES (2123, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:18.153836');
INSERT INTO "public"."launcher_download_log" VALUES (2124, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:18.211657');
INSERT INTO "public"."launcher_download_log" VALUES (2140, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:31:09.537556');
INSERT INTO "public"."launcher_download_log" VALUES (2142, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:31:09.56683');
INSERT INTO "public"."launcher_download_log" VALUES (2143, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:31:11.543551');
INSERT INTO "public"."launcher_download_log" VALUES (2144, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:31:11.567393');
INSERT INTO "public"."launcher_download_log" VALUES (2151, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:34.684175');
INSERT INTO "public"."launcher_download_log" VALUES (2152, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:34.971132');
INSERT INTO "public"."launcher_download_log" VALUES (2156, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:35.251899');
INSERT INTO "public"."launcher_download_log" VALUES (2170, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:17.052094');
INSERT INTO "public"."launcher_download_log" VALUES (2176, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:51.668675');
INSERT INTO "public"."launcher_download_log" VALUES (2177, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:51.882549');
INSERT INTO "public"."launcher_download_log" VALUES (2178, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:51.915291');
INSERT INTO "public"."launcher_download_log" VALUES (2179, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:50:53.667774');
INSERT INTO "public"."launcher_download_log" VALUES (2180, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:50:53.91345');
INSERT INTO "public"."launcher_download_log" VALUES (2182, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:51:21.54935');
INSERT INTO "public"."launcher_download_log" VALUES (2183, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:51:21.76733');
INSERT INTO "public"."launcher_download_log" VALUES (2184, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:51:21.795938');
INSERT INTO "public"."launcher_download_log" VALUES (2185, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:51:23.550954');
INSERT INTO "public"."launcher_download_log" VALUES (2186, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:51:23.797001');
INSERT INTO "public"."launcher_download_log" VALUES (2187, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:58:26.500672');
INSERT INTO "public"."launcher_download_log" VALUES (2189, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:58:26.65615');
INSERT INTO "public"."launcher_download_log" VALUES (2192, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:58:26.892063');
INSERT INTO "public"."launcher_download_log" VALUES (2200, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:02:41.94719');
INSERT INTO "public"."launcher_download_log" VALUES (2201, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:02:41.9631');
INSERT INTO "public"."launcher_download_log" VALUES (2203, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:02:42.196008');
INSERT INTO "public"."launcher_download_log" VALUES (2208, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:03:00.264424');
INSERT INTO "public"."launcher_download_log" VALUES (2210, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:03:00.515618');
INSERT INTO "public"."launcher_download_log" VALUES (2212, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:04:24.332812');
INSERT INTO "public"."launcher_download_log" VALUES (2213, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:04:24.346102');
INSERT INTO "public"."launcher_download_log" VALUES (2215, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:04:24.604397');
INSERT INTO "public"."launcher_download_log" VALUES (2217, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:04:58.798693');
INSERT INTO "public"."launcher_download_log" VALUES (2218, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:04:58.82608');
INSERT INTO "public"."launcher_download_log" VALUES (2220, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:04:59.064389');
INSERT INTO "public"."launcher_download_log" VALUES (2222, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:01.079066');
INSERT INTO "public"."launcher_download_log" VALUES (2225, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:29.029792');
INSERT INTO "public"."launcher_download_log" VALUES (2227, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:30.813774');
INSERT INTO "public"."launcher_download_log" VALUES (2230, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:05:58.823652');
INSERT INTO "public"."launcher_download_log" VALUES (2232, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:05:59.064557');
INSERT INTO "public"."launcher_download_log" VALUES (2234, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:06:01.126347');
INSERT INTO "public"."launcher_download_log" VALUES (2237, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:06:25.478328');
INSERT INTO "public"."launcher_download_log" VALUES (2238, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:06:25.522138');
INSERT INTO "public"."launcher_download_log" VALUES (875, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:38:24.777818');
INSERT INTO "public"."launcher_download_log" VALUES (877, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:38:25.02951');
INSERT INTO "public"."launcher_download_log" VALUES (879, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:38:25.129666');
INSERT INTO "public"."launcher_download_log" VALUES (881, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:38:59.526068');
INSERT INTO "public"."launcher_download_log" VALUES (882, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:38:59.539683');
INSERT INTO "public"."launcher_download_log" VALUES (884, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:01.56241');
INSERT INTO "public"."launcher_download_log" VALUES (886, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:33.36468');
INSERT INTO "public"."launcher_download_log" VALUES (887, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:33.404495');
INSERT INTO "public"."launcher_download_log" VALUES (888, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:33.552418');
INSERT INTO "public"."launcher_download_log" VALUES (889, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:33.591129');
INSERT INTO "public"."launcher_download_log" VALUES (890, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:33.670546');
INSERT INTO "public"."launcher_download_log" VALUES (891, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:33.699399');
INSERT INTO "public"."launcher_download_log" VALUES (892, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:34.403');
INSERT INTO "public"."launcher_download_log" VALUES (893, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:34.432858');
INSERT INTO "public"."launcher_download_log" VALUES (894, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:34.90719');
INSERT INTO "public"."launcher_download_log" VALUES (895, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:34.933768');
INSERT INTO "public"."launcher_download_log" VALUES (896, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:35.906422');
INSERT INTO "public"."launcher_download_log" VALUES (897, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:35.984486');
INSERT INTO "public"."launcher_download_log" VALUES (898, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:59.430082');
INSERT INTO "public"."launcher_download_log" VALUES (899, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:59.476213');
INSERT INTO "public"."launcher_download_log" VALUES (900, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:39:59.49483');
INSERT INTO "public"."launcher_download_log" VALUES (901, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:39:59.524162');
INSERT INTO "public"."launcher_download_log" VALUES (902, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:40:01.596446');
INSERT INTO "public"."launcher_download_log" VALUES (903, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:40:01.620811');
INSERT INTO "public"."launcher_download_log" VALUES (904, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:40:30.469163');
INSERT INTO "public"."launcher_download_log" VALUES (905, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:40:30.517282');
INSERT INTO "public"."launcher_download_log" VALUES (906, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:40:30.742967');
INSERT INTO "public"."launcher_download_log" VALUES (907, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:40:30.743721');
INSERT INTO "public"."launcher_download_log" VALUES (908, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:40:30.859676');
INSERT INTO "public"."launcher_download_log" VALUES (909, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:40:30.860053');
INSERT INTO "public"."launcher_download_log" VALUES (910, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:42:36.258134');
INSERT INTO "public"."launcher_download_log" VALUES (911, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:42:36.30649');
INSERT INTO "public"."launcher_download_log" VALUES (912, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:42:36.518096');
INSERT INTO "public"."launcher_download_log" VALUES (913, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:42:36.537021');
INSERT INTO "public"."launcher_download_log" VALUES (914, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:42:36.576347');
INSERT INTO "public"."launcher_download_log" VALUES (915, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:42:36.576756');
INSERT INTO "public"."launcher_download_log" VALUES (916, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:43:10.929417');
INSERT INTO "public"."launcher_download_log" VALUES (917, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:43:10.963588');
INSERT INTO "public"."launcher_download_log" VALUES (918, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:43:10.983775');
INSERT INTO "public"."launcher_download_log" VALUES (919, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:43:11.008163');
INSERT INTO "public"."launcher_download_log" VALUES (920, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:43:13.101252');
INSERT INTO "public"."launcher_download_log" VALUES (921, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:43:13.1238');
INSERT INTO "public"."launcher_download_log" VALUES (922, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:45:44.023817');
INSERT INTO "public"."launcher_download_log" VALUES (923, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:45:44.094516');
INSERT INTO "public"."launcher_download_log" VALUES (924, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:45:44.331248');
INSERT INTO "public"."launcher_download_log" VALUES (925, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:45:44.333236');
INSERT INTO "public"."launcher_download_log" VALUES (926, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:45:44.398886');
INSERT INTO "public"."launcher_download_log" VALUES (927, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:45:44.399224');
INSERT INTO "public"."launcher_download_log" VALUES (928, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:18.676407');
INSERT INTO "public"."launcher_download_log" VALUES (929, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:18.735923');
INSERT INTO "public"."launcher_download_log" VALUES (930, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:18.73639');
INSERT INTO "public"."launcher_download_log" VALUES (931, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:18.759945');
INSERT INTO "public"."launcher_download_log" VALUES (932, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:20.721005');
INSERT INTO "public"."launcher_download_log" VALUES (933, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:20.743852');
INSERT INTO "public"."launcher_download_log" VALUES (934, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:48.6959');
INSERT INTO "public"."launcher_download_log" VALUES (935, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:48.748903');
INSERT INTO "public"."launcher_download_log" VALUES (936, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:48.754057');
INSERT INTO "public"."launcher_download_log" VALUES (937, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:48.774862');
INSERT INTO "public"."launcher_download_log" VALUES (938, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:46:59.92146');
INSERT INTO "public"."launcher_download_log" VALUES (939, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:46:59.96693');
INSERT INTO "public"."launcher_download_log" VALUES (940, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:00.055889');
INSERT INTO "public"."launcher_download_log" VALUES (941, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:00.063489');
INSERT INTO "public"."launcher_download_log" VALUES (942, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:00.087789');
INSERT INTO "public"."launcher_download_log" VALUES (943, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:00.089842');
INSERT INTO "public"."launcher_download_log" VALUES (944, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:10.585722');
INSERT INTO "public"."launcher_download_log" VALUES (945, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:10.619525');
INSERT INTO "public"."launcher_download_log" VALUES (946, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:15.532094');
INSERT INTO "public"."launcher_download_log" VALUES (947, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:15.558449');
INSERT INTO "public"."launcher_download_log" VALUES (948, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:34.601492');
INSERT INTO "public"."launcher_download_log" VALUES (949, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:34.618548');
INSERT INTO "public"."launcher_download_log" VALUES (950, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:34.632175');
INSERT INTO "public"."launcher_download_log" VALUES (951, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:34.645821');
INSERT INTO "public"."launcher_download_log" VALUES (952, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:36.617649');
INSERT INTO "public"."launcher_download_log" VALUES (953, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:36.638996');
INSERT INTO "public"."launcher_download_log" VALUES (954, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:47:42.940432');
INSERT INTO "public"."launcher_download_log" VALUES (955, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:47:42.96639');
INSERT INTO "public"."launcher_download_log" VALUES (956, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:04.567651');
INSERT INTO "public"."launcher_download_log" VALUES (957, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:04.585964');
INSERT INTO "public"."launcher_download_log" VALUES (958, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:04.595701');
INSERT INTO "public"."launcher_download_log" VALUES (959, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:04.61053');
INSERT INTO "public"."launcher_download_log" VALUES (960, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:06.599097');
INSERT INTO "public"."launcher_download_log" VALUES (961, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:06.620787');
INSERT INTO "public"."launcher_download_log" VALUES (962, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:34.570282');
INSERT INTO "public"."launcher_download_log" VALUES (963, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:34.585337');
INSERT INTO "public"."launcher_download_log" VALUES (964, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:34.598302');
INSERT INTO "public"."launcher_download_log" VALUES (965, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:34.60927');
INSERT INTO "public"."launcher_download_log" VALUES (966, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:48:36.610874');
INSERT INTO "public"."launcher_download_log" VALUES (967, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:48:36.63212');
INSERT INTO "public"."launcher_download_log" VALUES (968, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:06.616901');
INSERT INTO "public"."launcher_download_log" VALUES (969, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:06.635508');
INSERT INTO "public"."launcher_download_log" VALUES (970, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:06.642867');
INSERT INTO "public"."launcher_download_log" VALUES (971, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:06.660375');
INSERT INTO "public"."launcher_download_log" VALUES (972, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:08.649871');
INSERT INTO "public"."launcher_download_log" VALUES (973, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:08.674394');
INSERT INTO "public"."launcher_download_log" VALUES (974, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:27.44459');
INSERT INTO "public"."launcher_download_log" VALUES (975, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:27.584549');
INSERT INTO "public"."launcher_download_log" VALUES (976, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:49:27.628034');
INSERT INTO "public"."launcher_download_log" VALUES (977, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:27.656901');
INSERT INTO "public"."launcher_download_log" VALUES (978, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:27.982682');
INSERT INTO "public"."launcher_download_log" VALUES (979, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:49:27.98421');
INSERT INTO "public"."launcher_download_log" VALUES (980, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:02.137758');
INSERT INTO "public"."launcher_download_log" VALUES (981, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:02.164042');
INSERT INTO "public"."launcher_download_log" VALUES (982, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:02.168723');
INSERT INTO "public"."launcher_download_log" VALUES (984, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:04.173844');
INSERT INTO "public"."launcher_download_log" VALUES (986, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:11.731691');
INSERT INTO "public"."launcher_download_log" VALUES (991, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:32.174376');
INSERT INTO "public"."launcher_download_log" VALUES (994, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:02.117566');
INSERT INTO "public"."launcher_download_log" VALUES (995, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:02.136793');
INSERT INTO "public"."launcher_download_log" VALUES (999, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:04.180409');
INSERT INTO "public"."launcher_download_log" VALUES (1002, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:34.16609');
INSERT INTO "public"."launcher_download_log" VALUES (1008, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:02.137612');
INSERT INTO "public"."launcher_download_log" VALUES (1009, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:02.156323');
INSERT INTO "public"."launcher_download_log" VALUES (1016, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:37.760565');
INSERT INTO "public"."launcher_download_log" VALUES (1020, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:12.151588');
INSERT INTO "public"."launcher_download_log" VALUES (1021, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:12.201691');
INSERT INTO "public"."launcher_download_log" VALUES (1032, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:44.128365');
INSERT INTO "public"."launcher_download_log" VALUES (1039, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:14.155773');
INSERT INTO "public"."launcher_download_log" VALUES (1044, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:46.205492');
INSERT INTO "public"."launcher_download_log" VALUES (1046, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:55:08.633252');
INSERT INTO "public"."launcher_download_log" VALUES (1047, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:55:08.6763');
INSERT INTO "public"."launcher_download_log" VALUES (1048, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:55:08.830854');
INSERT INTO "public"."launcher_download_log" VALUES (1051, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:55:08.906278');
INSERT INTO "public"."launcher_download_log" VALUES (1056, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:56:16.978651');
INSERT INTO "public"."launcher_download_log" VALUES (1058, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:59:01.586763');
INSERT INTO "public"."launcher_download_log" VALUES (1059, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:59:01.634427');
INSERT INTO "public"."launcher_download_log" VALUES (1060, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:59:01.809483');
INSERT INTO "public"."launcher_download_log" VALUES (1063, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:59:01.881103');
INSERT INTO "public"."launcher_download_log" VALUES (1064, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:02:51.967805');
INSERT INTO "public"."launcher_download_log" VALUES (1065, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:02:52.011663');
INSERT INTO "public"."launcher_download_log" VALUES (1070, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:05:34.826472');
INSERT INTO "public"."launcher_download_log" VALUES (1071, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:05:34.870652');
INSERT INTO "public"."launcher_download_log" VALUES (1072, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:05:35.041842');
INSERT INTO "public"."launcher_download_log" VALUES (1078, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:05:59.083752');
INSERT INTO "public"."launcher_download_log" VALUES (1085, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:06:11.603585');
INSERT INTO "public"."launcher_download_log" VALUES (1089, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:08.908063');
INSERT INTO "public"."launcher_download_log" VALUES (1092, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:43.397333');
INSERT INTO "public"."launcher_download_log" VALUES (1094, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:43.46935');
INSERT INTO "public"."launcher_download_log" VALUES (1458, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:15.429835');
INSERT INTO "public"."launcher_download_log" VALUES (1460, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:15.46018');
INSERT INTO "public"."launcher_download_log" VALUES (1461, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:17.443045');
INSERT INTO "public"."launcher_download_log" VALUES (1462, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:17.468455');
INSERT INTO "public"."launcher_download_log" VALUES (1463, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:43.346031');
INSERT INTO "public"."launcher_download_log" VALUES (1675, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:08.680472');
INSERT INTO "public"."launcher_download_log" VALUES (1676, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:08.754426');
INSERT INTO "public"."launcher_download_log" VALUES (1677, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:08.858251');
INSERT INTO "public"."launcher_download_log" VALUES (1678, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:08.888088');
INSERT INTO "public"."launcher_download_log" VALUES (1681, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:43.34991');
INSERT INTO "public"."launcher_download_log" VALUES (1682, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:43.389749');
INSERT INTO "public"."launcher_download_log" VALUES (1684, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:43.41813');
INSERT INTO "public"."launcher_download_log" VALUES (1686, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:45.411046');
INSERT INTO "public"."launcher_download_log" VALUES (1687, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:55:14.729658');
INSERT INTO "public"."launcher_download_log" VALUES (1688, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:55:14.800872');
INSERT INTO "public"."launcher_download_log" VALUES (1690, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:55:14.866965');
INSERT INTO "public"."launcher_download_log" VALUES (1692, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:55:14.902322');
INSERT INTO "public"."launcher_download_log" VALUES (1693, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:56:42.376124');
INSERT INTO "public"."launcher_download_log" VALUES (1694, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:56:42.419799');
INSERT INTO "public"."launcher_download_log" VALUES (1695, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:56:42.54332');
INSERT INTO "public"."launcher_download_log" VALUES (1697, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:56:42.573788');
INSERT INTO "public"."launcher_download_log" VALUES (1699, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:22:40.432499');
INSERT INTO "public"."launcher_download_log" VALUES (1701, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:22:40.58983');
INSERT INTO "public"."launcher_download_log" VALUES (1703, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:22:40.640228');
INSERT INTO "public"."launcher_download_log" VALUES (1710, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:17.117306');
INSERT INTO "public"."launcher_download_log" VALUES (1712, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:41.838955');
INSERT INTO "public"."launcher_download_log" VALUES (1714, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:41.954453');
INSERT INTO "public"."launcher_download_log" VALUES (1716, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:41.984517');
INSERT INTO "public"."launcher_download_log" VALUES (1717, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:16.460646');
INSERT INTO "public"."launcher_download_log" VALUES (1718, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:16.482849');
INSERT INTO "public"."launcher_download_log" VALUES (1721, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:18.477346');
INSERT INTO "public"."launcher_download_log" VALUES (1723, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:46.451651');
INSERT INTO "public"."launcher_download_log" VALUES (1724, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:46.476152');
INSERT INTO "public"."launcher_download_log" VALUES (1725, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:46.492065');
INSERT INTO "public"."launcher_download_log" VALUES (1728, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:48.513875');
INSERT INTO "public"."launcher_download_log" VALUES (1731, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:59.795717');
INSERT INTO "public"."launcher_download_log" VALUES (1734, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:59.830394');
INSERT INTO "public"."launcher_download_log" VALUES (1736, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:25:34.122292');
INSERT INTO "public"."launcher_download_log" VALUES (1738, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:25:34.147907');
INSERT INTO "public"."launcher_download_log" VALUES (1740, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:25:36.154028');
INSERT INTO "public"."launcher_download_log" VALUES (1747, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:11.336908');
INSERT INTO "public"."launcher_download_log" VALUES (1749, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:11.367477');
INSERT INTO "public"."launcher_download_log" VALUES (1751, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:58.873875');
INSERT INTO "public"."launcher_download_log" VALUES (1753, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:58.916973');
INSERT INTO "public"."launcher_download_log" VALUES (1755, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:00.933059');
INSERT INTO "public"."launcher_download_log" VALUES (1759, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:15.695394');
INSERT INTO "public"."launcher_download_log" VALUES (1760, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:15.718087');
INSERT INTO "public"."launcher_download_log" VALUES (1762, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:17.751976');
INSERT INTO "public"."launcher_download_log" VALUES (1764, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:56.427954');
INSERT INTO "public"."launcher_download_log" VALUES (1767, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:58.426499');
INSERT INTO "public"."launcher_download_log" VALUES (1769, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:28:21.6363');
INSERT INTO "public"."launcher_download_log" VALUES (1770, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:28:21.690112');
INSERT INTO "public"."launcher_download_log" VALUES (1771, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:28:21.876553');
INSERT INTO "public"."launcher_download_log" VALUES (1772, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:28:21.984884');
INSERT INTO "public"."launcher_download_log" VALUES (1923, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:18:22.951117');
INSERT INTO "public"."launcher_download_log" VALUES (1924, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:18:22.985105');
INSERT INTO "public"."launcher_download_log" VALUES (1926, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:19:25.804125');
INSERT INTO "public"."launcher_download_log" VALUES (1927, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:19:25.867054');
INSERT INTO "public"."launcher_download_log" VALUES (1928, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:19:26.060742');
INSERT INTO "public"."launcher_download_log" VALUES (1931, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:19:26.132045');
INSERT INTO "public"."launcher_download_log" VALUES (1934, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:00.576355');
INSERT INTO "public"."launcher_download_log" VALUES (1935, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:00.59735');
INSERT INTO "public"."launcher_download_log" VALUES (1937, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:02.59651');
INSERT INTO "public"."launcher_download_log" VALUES (1938, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:30.466175');
INSERT INTO "public"."launcher_download_log" VALUES (1940, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:30.511909');
INSERT INTO "public"."launcher_download_log" VALUES (1941, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:30.542863');
INSERT INTO "public"."launcher_download_log" VALUES (1943, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:32.533111');
INSERT INTO "public"."launcher_download_log" VALUES (983, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:02.190321');
INSERT INTO "public"."launcher_download_log" VALUES (990, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:32.15887');
INSERT INTO "public"."launcher_download_log" VALUES (996, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:02.145777');
INSERT INTO "public"."launcher_download_log" VALUES (997, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:02.164131');
INSERT INTO "public"."launcher_download_log" VALUES (1000, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:34.137387');
INSERT INTO "public"."launcher_download_log" VALUES (1001, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:34.155972');
INSERT INTO "public"."launcher_download_log" VALUES (1005, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:36.189995');
INSERT INTO "public"."launcher_download_log" VALUES (1010, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:04.141319');
INSERT INTO "public"."launcher_download_log" VALUES (1015, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:37.697292');
INSERT INTO "public"."launcher_download_log" VALUES (1025, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:14.212096');
INSERT INTO "public"."launcher_download_log" VALUES (1031, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:42.109331');
INSERT INTO "public"."launcher_download_log" VALUES (1034, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:12.076613');
INSERT INTO "public"."launcher_download_log" VALUES (1035, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:12.105288');
INSERT INTO "public"."launcher_download_log" VALUES (1042, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:44.215924');
INSERT INTO "public"."launcher_download_log" VALUES (1043, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:44.234291');
INSERT INTO "public"."launcher_download_log" VALUES (1055, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:56:16.925296');
INSERT INTO "public"."launcher_download_log" VALUES (1062, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:59:01.880658');
INSERT INTO "public"."launcher_download_log" VALUES (1066, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:02:52.243386');
INSERT INTO "public"."launcher_download_log" VALUES (1069, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:02:52.293514');
INSERT INTO "public"."launcher_download_log" VALUES (1076, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:05:57.706528');
INSERT INTO "public"."launcher_download_log" VALUES (1083, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:06:09.608198');
INSERT INTO "public"."launcher_download_log" VALUES (1096, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:45.478487');
INSERT INTO "public"."launcher_download_log" VALUES (1459, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:15.432873');
INSERT INTO "public"."launcher_download_log" VALUES (1465, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:43.389654');
INSERT INTO "public"."launcher_download_log" VALUES (1466, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:43.41883');
INSERT INTO "public"."launcher_download_log" VALUES (1467, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 02:20:45.386315');
INSERT INTO "public"."launcher_download_log" VALUES (1468, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 02:20:45.411848');
INSERT INTO "public"."launcher_download_log" VALUES (1679, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:08.893529');
INSERT INTO "public"."launcher_download_log" VALUES (1680, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:08.919581');
INSERT INTO "public"."launcher_download_log" VALUES (1683, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:21:43.391059');
INSERT INTO "public"."launcher_download_log" VALUES (1685, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:21:45.38796');
INSERT INTO "public"."launcher_download_log" VALUES (1689, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:55:14.865319');
INSERT INTO "public"."launcher_download_log" VALUES (1691, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:55:14.901974');
INSERT INTO "public"."launcher_download_log" VALUES (1696, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 22:56:42.543651');
INSERT INTO "public"."launcher_download_log" VALUES (1698, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 22:56:42.574176');
INSERT INTO "public"."launcher_download_log" VALUES (1700, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:22:40.478503');
INSERT INTO "public"."launcher_download_log" VALUES (1702, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:22:40.591864');
INSERT INTO "public"."launcher_download_log" VALUES (1704, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:22:40.640587');
INSERT INTO "public"."launcher_download_log" VALUES (1705, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:15.064698');
INSERT INTO "public"."launcher_download_log" VALUES (1706, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:15.081542');
INSERT INTO "public"."launcher_download_log" VALUES (1707, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:15.096186');
INSERT INTO "public"."launcher_download_log" VALUES (1708, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:15.105979');
INSERT INTO "public"."launcher_download_log" VALUES (1709, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:17.095849');
INSERT INTO "public"."launcher_download_log" VALUES (1711, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:41.790132');
INSERT INTO "public"."launcher_download_log" VALUES (1713, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:23:41.95406');
INSERT INTO "public"."launcher_download_log" VALUES (1715, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:23:41.984182');
INSERT INTO "public"."launcher_download_log" VALUES (1719, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:16.487885');
INSERT INTO "public"."launcher_download_log" VALUES (1720, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:16.508094');
INSERT INTO "public"."launcher_download_log" VALUES (1722, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:18.504098');
INSERT INTO "public"."launcher_download_log" VALUES (1726, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:46.502486');
INSERT INTO "public"."launcher_download_log" VALUES (1727, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:48.489626');
INSERT INTO "public"."launcher_download_log" VALUES (1729, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:59.46428');
INSERT INTO "public"."launcher_download_log" VALUES (1730, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:59.520126');
INSERT INTO "public"."launcher_download_log" VALUES (1732, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:24:59.801349');
INSERT INTO "public"."launcher_download_log" VALUES (1733, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:24:59.827543');
INSERT INTO "public"."launcher_download_log" VALUES (1735, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:25:34.097964');
INSERT INTO "public"."launcher_download_log" VALUES (1737, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:25:34.130834');
INSERT INTO "public"."launcher_download_log" VALUES (1739, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:25:36.130423');
INSERT INTO "public"."launcher_download_log" VALUES (1741, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:04.051926');
INSERT INTO "public"."launcher_download_log" VALUES (1742, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:04.072265');
INSERT INTO "public"."launcher_download_log" VALUES (1743, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:04.100889');
INSERT INTO "public"."launcher_download_log" VALUES (1744, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:04.112126');
INSERT INTO "public"."launcher_download_log" VALUES (1745, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:10.993297');
INSERT INTO "public"."launcher_download_log" VALUES (1746, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:11.047952');
INSERT INTO "public"."launcher_download_log" VALUES (1748, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:11.337514');
INSERT INTO "public"."launcher_download_log" VALUES (1750, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:11.368067');
INSERT INTO "public"."launcher_download_log" VALUES (1752, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:26:58.915616');
INSERT INTO "public"."launcher_download_log" VALUES (1754, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:26:58.942122');
INSERT INTO "public"."launcher_download_log" VALUES (1756, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:00.955598');
INSERT INTO "public"."launcher_download_log" VALUES (1757, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:15.653376');
INSERT INTO "public"."launcher_download_log" VALUES (1758, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:15.691671');
INSERT INTO "public"."launcher_download_log" VALUES (1761, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:17.727498');
INSERT INTO "public"."launcher_download_log" VALUES (1763, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:27:56.365609');
INSERT INTO "public"."launcher_download_log" VALUES (1765, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:56.433091');
INSERT INTO "public"."launcher_download_log" VALUES (1766, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:56.466058');
INSERT INTO "public"."launcher_download_log" VALUES (1768, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:27:58.449206');
INSERT INTO "public"."launcher_download_log" VALUES (1944, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:45.70349');
INSERT INTO "public"."launcher_download_log" VALUES (1946, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:20:45.826023');
INSERT INTO "public"."launcher_download_log" VALUES (1949, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:20:45.871629');
INSERT INTO "public"."launcher_download_log" VALUES (1951, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:25.839861');
INSERT INTO "public"."launcher_download_log" VALUES (1952, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:25.988161');
INSERT INTO "public"."launcher_download_log" VALUES (1955, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:26.077514');
INSERT INTO "public"."launcher_download_log" VALUES (1959, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:21:47.60818');
INSERT INTO "public"."launcher_download_log" VALUES (1961, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:21:47.666794');
INSERT INTO "public"."launcher_download_log" VALUES (1964, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:21.966825');
INSERT INTO "public"."launcher_download_log" VALUES (1978, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:31:00.663881');
INSERT INTO "public"."launcher_download_log" VALUES (1979, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:31:00.709827');
INSERT INTO "public"."launcher_download_log" VALUES (1982, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:31:00.832138');
INSERT INTO "public"."launcher_download_log" VALUES (1984, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:31:00.858467');
INSERT INTO "public"."launcher_download_log" VALUES (1990, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:32:37.868637');
INSERT INTO "public"."launcher_download_log" VALUES (1993, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:32:37.943636');
INSERT INTO "public"."launcher_download_log" VALUES (1999, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:12.265383');
INSERT INTO "public"."launcher_download_log" VALUES (2004, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:42.272227');
INSERT INTO "public"."launcher_download_log" VALUES (2006, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:33:42.309283');
INSERT INTO "public"."launcher_download_log" VALUES (2106, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:25:01.846776');
INSERT INTO "public"."launcher_download_log" VALUES (2121, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:29:13.826376');
INSERT INTO "public"."launcher_download_log" VALUES (2127, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:18.339125');
INSERT INTO "public"."launcher_download_log" VALUES (2129, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:18.377819');
INSERT INTO "public"."launcher_download_log" VALUES (2132, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:30:34.964874');
INSERT INTO "public"."launcher_download_log" VALUES (2133, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:35.011786');
INSERT INTO "public"."launcher_download_log" VALUES (2135, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:35.044815');
INSERT INTO "public"."launcher_download_log" VALUES (2137, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:30:49.701737');
INSERT INTO "public"."launcher_download_log" VALUES (985, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:04.271581');
INSERT INTO "public"."launcher_download_log" VALUES (987, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:11.759724');
INSERT INTO "public"."launcher_download_log" VALUES (988, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:32.126771');
INSERT INTO "public"."launcher_download_log" VALUES (989, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:32.144957');
INSERT INTO "public"."launcher_download_log" VALUES (993, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:50:34.178812');
INSERT INTO "public"."launcher_download_log" VALUES (998, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:04.15853');
INSERT INTO "public"."launcher_download_log" VALUES (1004, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:51:36.168568');
INSERT INTO "public"."launcher_download_log" VALUES (1012, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:37.408792');
INSERT INTO "public"."launcher_download_log" VALUES (1013, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:37.454928');
INSERT INTO "public"."launcher_download_log" VALUES (1017, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:37.760999');
INSERT INTO "public"."launcher_download_log" VALUES (1019, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:48.988166');
INSERT INTO "public"."launcher_download_log" VALUES (1023, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:12.234258');
INSERT INTO "public"."launcher_download_log" VALUES (1026, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:14.982393');
INSERT INTO "public"."launcher_download_log" VALUES (1030, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:42.095455');
INSERT INTO "public"."launcher_download_log" VALUES (1037, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:12.129709');
INSERT INTO "public"."launcher_download_log" VALUES (1040, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:44.16443');
INSERT INTO "public"."launcher_download_log" VALUES (1041, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:44.208784');
INSERT INTO "public"."launcher_download_log" VALUES (1045, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:46.228209');
INSERT INTO "public"."launcher_download_log" VALUES (1050, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:55:08.905439');
INSERT INTO "public"."launcher_download_log" VALUES (1073, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:05:35.051443');
INSERT INTO "public"."launcher_download_log" VALUES (1074, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:05:35.069098');
INSERT INTO "public"."launcher_download_log" VALUES (1079, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:05:59.110351');
INSERT INTO "public"."launcher_download_log" VALUES (1082, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:06:09.588503');
INSERT INTO "public"."launcher_download_log" VALUES (1084, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:06:11.579485');
INSERT INTO "public"."launcher_download_log" VALUES (1090, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:08.930543');
INSERT INTO "public"."launcher_download_log" VALUES (1095, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:43.495165');
INSERT INTO "public"."launcher_download_log" VALUES (1097, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:45.500719');
INSERT INTO "public"."launcher_download_log" VALUES (1469, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:05:57.556337');
INSERT INTO "public"."launcher_download_log" VALUES (1470, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:05:57.632033');
INSERT INTO "public"."launcher_download_log" VALUES (1471, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:10.69788');
INSERT INTO "public"."launcher_download_log" VALUES (1473, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:10.981684');
INSERT INTO "public"."launcher_download_log" VALUES (1475, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:11.043913');
INSERT INTO "public"."launcher_download_log" VALUES (1479, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:45.435571');
INSERT INTO "public"."launcher_download_log" VALUES (1481, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:47.459579');
INSERT INTO "public"."launcher_download_log" VALUES (1485, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:15.408631');
INSERT INTO "public"."launcher_download_log" VALUES (1486, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:15.436598');
INSERT INTO "public"."launcher_download_log" VALUES (1488, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:17.444876');
INSERT INTO "public"."launcher_download_log" VALUES (1489, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:45.335767');
INSERT INTO "public"."launcher_download_log" VALUES (1490, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:45.365177');
INSERT INTO "public"."launcher_download_log" VALUES (1493, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:47.42452');
INSERT INTO "public"."launcher_download_log" VALUES (1496, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:14.43691');
INSERT INTO "public"."launcher_download_log" VALUES (1497, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:14.606481');
INSERT INTO "public"."launcher_download_log" VALUES (1500, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:14.683233');
INSERT INTO "public"."launcher_download_log" VALUES (1773, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:37:36.266208');
INSERT INTO "public"."launcher_download_log" VALUES (1775, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:37:36.396477');
INSERT INTO "public"."launcher_download_log" VALUES (1778, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:37:36.433375');
INSERT INTO "public"."launcher_download_log" VALUES (1780, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:39:21.23095');
INSERT INTO "public"."launcher_download_log" VALUES (1782, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:39:21.274737');
INSERT INTO "public"."launcher_download_log" VALUES (1785, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:00.304195');
INSERT INTO "public"."launcher_download_log" VALUES (1786, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:00.348855');
INSERT INTO "public"."launcher_download_log" VALUES (1792, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:49.744475');
INSERT INTO "public"."launcher_download_log" VALUES (1795, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:49.985766');
INSERT INTO "public"."launcher_download_log" VALUES (1800, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:41:58.61797');
INSERT INTO "public"."launcher_download_log" VALUES (1802, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:41:58.647269');
INSERT INTO "public"."launcher_download_log" VALUES (1805, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:42:12.618828');
INSERT INTO "public"."launcher_download_log" VALUES (1811, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:42:47.578729');
INSERT INTO "public"."launcher_download_log" VALUES (1812, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:42:47.602221');
INSERT INTO "public"."launcher_download_log" VALUES (1815, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:43:27.684387');
INSERT INTO "public"."launcher_download_log" VALUES (1817, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:43:27.763133');
INSERT INTO "public"."launcher_download_log" VALUES (1821, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:44:02.132858');
INSERT INTO "public"."launcher_download_log" VALUES (1965, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:22.005783');
INSERT INTO "public"."launcher_download_log" VALUES (1967, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:22.034592');
INSERT INTO "public"."launcher_download_log" VALUES (1968, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:24.027779');
INSERT INTO "public"."launcher_download_log" VALUES (1969, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:24.051813');
INSERT INTO "public"."launcher_download_log" VALUES (1970, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:25.170855');
INSERT INTO "public"."launcher_download_log" VALUES (1971, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:25.194462');
INSERT INTO "public"."launcher_download_log" VALUES (1972, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:22:29.923987');
INSERT INTO "public"."launcher_download_log" VALUES (1973, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:22:29.952042');
INSERT INTO "public"."launcher_download_log" VALUES (1974, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'Nuevo_documento_de_texto.txt', 'game_file', 't', '2025-06-05 00:22:53.528256');
INSERT INTO "public"."launcher_download_log" VALUES (1975, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'Nuevo_documento_de_texto.txt', 'game_file', 't', '2025-06-05 00:23:00.267362');
INSERT INTO "public"."launcher_download_log" VALUES (1976, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'Nuevo_documento_de_texto.txt', 'game_file', 't', '2025-06-05 00:28:37.066821');
INSERT INTO "public"."launcher_download_log" VALUES (1977, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'Nuevo_documento_de_texto.txt', 'game_file', 't', '2025-06-05 00:29:03.211442');
INSERT INTO "public"."launcher_download_log" VALUES (1980, '127.0.0.1', '', 'WinPcap_4_1_3.exe', 'game_file', 't', '2025-06-05 00:31:00.781974');
INSERT INTO "public"."launcher_download_log" VALUES (1981, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:31:00.831795');
INSERT INTO "public"."launcher_download_log" VALUES (1983, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:31:00.858102');
INSERT INTO "public"."launcher_download_log" VALUES (1985, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:31:07.97937');
INSERT INTO "public"."launcher_download_log" VALUES (1986, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:31:08.00241');
INSERT INTO "public"."launcher_download_log" VALUES (1988, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:32:37.670657');
INSERT INTO "public"."launcher_download_log" VALUES (1989, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 00:32:37.727995');
INSERT INTO "public"."launcher_download_log" VALUES (1994, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:32:57.86253');
INSERT INTO "public"."launcher_download_log" VALUES (1995, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 00:32:57.885611');
INSERT INTO "public"."launcher_download_log" VALUES (1996, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 00:32:57.92341');
INSERT INTO "public"."launcher_download_log" VALUES (1997, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 00:33:12.23025');
INSERT INTO "public"."launcher_download_log" VALUES (2001, '127.0.0.1', '', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 00:33:12.291615');
INSERT INTO "public"."launcher_download_log" VALUES (2112, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', '61AlyhAAEL._AC_UF8941000_QL80_.jpg', 'game_file', 't', '2025-06-05 02:26:35.181734');
INSERT INTO "public"."launcher_download_log" VALUES (2138, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:30:49.744421');
INSERT INTO "public"."launcher_download_log" VALUES (2139, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:31:09.512277');
INSERT INTO "public"."launcher_download_log" VALUES (2145, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:20.96713');
INSERT INTO "public"."launcher_download_log" VALUES (2147, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:21.159472');
INSERT INTO "public"."launcher_download_log" VALUES (2153, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:39:34.972676');
INSERT INTO "public"."launcher_download_log" VALUES (2155, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:39:35.251511');
INSERT INTO "public"."launcher_download_log" VALUES (2157, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:07.411243');
INSERT INTO "public"."launcher_download_log" VALUES (2158, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:46:07.680817');
INSERT INTO "public"."launcher_download_log" VALUES (992, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:50:34.14329');
INSERT INTO "public"."launcher_download_log" VALUES (1003, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:51:34.180826');
INSERT INTO "public"."launcher_download_log" VALUES (1006, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:02.111488');
INSERT INTO "public"."launcher_download_log" VALUES (1007, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:02.129794');
INSERT INTO "public"."launcher_download_log" VALUES (1011, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:52:04.162741');
INSERT INTO "public"."launcher_download_log" VALUES (1014, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:37.693789');
INSERT INTO "public"."launcher_download_log" VALUES (1018, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:52:48.951164');
INSERT INTO "public"."launcher_download_log" VALUES (1022, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:12.206751');
INSERT INTO "public"."launcher_download_log" VALUES (1024, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:14.187887');
INSERT INTO "public"."launcher_download_log" VALUES (1027, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:15.006342');
INSERT INTO "public"."launcher_download_log" VALUES (1028, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:42.063302');
INSERT INTO "public"."launcher_download_log" VALUES (1029, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:53:42.084278');
INSERT INTO "public"."launcher_download_log" VALUES (1033, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:53:44.155285');
INSERT INTO "public"."launcher_download_log" VALUES (1036, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:54:12.108436');
INSERT INTO "public"."launcher_download_log" VALUES (1038, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:54:14.133122');
INSERT INTO "public"."launcher_download_log" VALUES (1049, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:55:08.832232');
INSERT INTO "public"."launcher_download_log" VALUES (1052, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:56:16.690375');
INSERT INTO "public"."launcher_download_log" VALUES (1053, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:56:16.732518');
INSERT INTO "public"."launcher_download_log" VALUES (1054, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:56:16.924807');
INSERT INTO "public"."launcher_download_log" VALUES (1057, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 20:56:16.979042');
INSERT INTO "public"."launcher_download_log" VALUES (1061, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 20:59:01.810298');
INSERT INTO "public"."launcher_download_log" VALUES (1067, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:02:52.261199');
INSERT INTO "public"."launcher_download_log" VALUES (1068, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:02:52.28361');
INSERT INTO "public"."launcher_download_log" VALUES (1075, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:05:35.077238');
INSERT INTO "public"."launcher_download_log" VALUES (1077, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:05:57.734312');
INSERT INTO "public"."launcher_download_log" VALUES (1080, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:06:09.529621');
INSERT INTO "public"."launcher_download_log" VALUES (1081, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:06:09.58391');
INSERT INTO "public"."launcher_download_log" VALUES (1086, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:08.674382');
INSERT INTO "public"."launcher_download_log" VALUES (1087, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:08.719399');
INSERT INTO "public"."launcher_download_log" VALUES (1088, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:08.904387');
INSERT INTO "public"."launcher_download_log" VALUES (1091, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:09:08.932588');
INSERT INTO "public"."launcher_download_log" VALUES (1093, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:09:43.467412');
INSERT INTO "public"."launcher_download_log" VALUES (1098, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:13.367897');
INSERT INTO "public"."launcher_download_log" VALUES (1099, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:13.373958');
INSERT INTO "public"."launcher_download_log" VALUES (1100, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:13.394137');
INSERT INTO "public"."launcher_download_log" VALUES (1101, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:13.396889');
INSERT INTO "public"."launcher_download_log" VALUES (1102, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:15.380001');
INSERT INTO "public"."launcher_download_log" VALUES (1103, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:15.400565');
INSERT INTO "public"."launcher_download_log" VALUES (1104, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:43.332016');
INSERT INTO "public"."launcher_download_log" VALUES (1105, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:43.37289');
INSERT INTO "public"."launcher_download_log" VALUES (1106, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:43.373273');
INSERT INTO "public"."launcher_download_log" VALUES (1107, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:43.398483');
INSERT INTO "public"."launcher_download_log" VALUES (1108, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:10:45.47181');
INSERT INTO "public"."launcher_download_log" VALUES (1109, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:10:45.496373');
INSERT INTO "public"."launcher_download_log" VALUES (1110, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:15.400991');
INSERT INTO "public"."launcher_download_log" VALUES (1111, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:15.41435');
INSERT INTO "public"."launcher_download_log" VALUES (1112, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:15.432527');
INSERT INTO "public"."launcher_download_log" VALUES (1113, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:15.446175');
INSERT INTO "public"."launcher_download_log" VALUES (1114, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:17.444246');
INSERT INTO "public"."launcher_download_log" VALUES (1115, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:17.469223');
INSERT INTO "public"."launcher_download_log" VALUES (1116, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:43.360007');
INSERT INTO "public"."launcher_download_log" VALUES (1117, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:43.380854');
INSERT INTO "public"."launcher_download_log" VALUES (1118, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:43.394293');
INSERT INTO "public"."launcher_download_log" VALUES (1119, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:43.406612');
INSERT INTO "public"."launcher_download_log" VALUES (1120, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:11:45.421037');
INSERT INTO "public"."launcher_download_log" VALUES (1121, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:11:45.445408');
INSERT INTO "public"."launcher_download_log" VALUES (1122, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:12:13.364008');
INSERT INTO "public"."launcher_download_log" VALUES (1123, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:12:13.396368');
INSERT INTO "public"."launcher_download_log" VALUES (1124, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:12:13.406701');
INSERT INTO "public"."launcher_download_log" VALUES (1125, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:12:13.424854');
INSERT INTO "public"."launcher_download_log" VALUES (1126, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:12:15.405931');
INSERT INTO "public"."launcher_download_log" VALUES (1127, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:12:15.428915');
INSERT INTO "public"."launcher_download_log" VALUES (1128, '127.0.0.1', '', 'update_1.0.0.1.zip', 'update', 't', '2025-06-03 21:12:15.460676');
INSERT INTO "public"."launcher_download_log" VALUES (1129, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:12:23.287665');
INSERT INTO "public"."launcher_download_log" VALUES (1130, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:37:39.135006');
INSERT INTO "public"."launcher_download_log" VALUES (1131, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:37:39.192545');
INSERT INTO "public"."launcher_download_log" VALUES (1132, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:37:39.352854');
INSERT INTO "public"."launcher_download_log" VALUES (1133, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:37:39.369614');
INSERT INTO "public"."launcher_download_log" VALUES (1134, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:37:39.384312');
INSERT INTO "public"."launcher_download_log" VALUES (1135, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:37:39.397361');
INSERT INTO "public"."launcher_download_log" VALUES (1136, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:37:47.307514');
INSERT INTO "public"."launcher_download_log" VALUES (1137, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:38:13.782569');
INSERT INTO "public"."launcher_download_log" VALUES (1138, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:38:13.789786');
INSERT INTO "public"."launcher_download_log" VALUES (1139, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:38:13.81135');
INSERT INTO "public"."launcher_download_log" VALUES (1140, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:38:13.814682');
INSERT INTO "public"."launcher_download_log" VALUES (1141, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:38:15.826103');
INSERT INTO "public"."launcher_download_log" VALUES (1142, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:38:15.849027');
INSERT INTO "public"."launcher_download_log" VALUES (1143, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:39:25.31778');
INSERT INTO "public"."launcher_download_log" VALUES (1144, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:39:25.383367');
INSERT INTO "public"."launcher_download_log" VALUES (1145, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:39:25.471246');
INSERT INTO "public"."launcher_download_log" VALUES (1146, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:39:25.474425');
INSERT INTO "public"."launcher_download_log" VALUES (1147, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:39:25.509484');
INSERT INTO "public"."launcher_download_log" VALUES (1148, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:39:25.510087');
INSERT INTO "public"."launcher_download_log" VALUES (1149, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:39:36.802481');
INSERT INTO "public"."launcher_download_log" VALUES (1150, '127.0.0.1', '', 'update_1.0.0.1.zip', 'update', 't', '2025-06-03 21:39:36.826345');
INSERT INTO "public"."launcher_download_log" VALUES (1151, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:00.01368');
INSERT INTO "public"."launcher_download_log" VALUES (1152, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:00.03746');
INSERT INTO "public"."launcher_download_log" VALUES (1153, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:00.048817');
INSERT INTO "public"."launcher_download_log" VALUES (1154, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:00.062504');
INSERT INTO "public"."launcher_download_log" VALUES (1155, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:02.050615');
INSERT INTO "public"."launcher_download_log" VALUES (1156, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:02.070829');
INSERT INTO "public"."launcher_download_log" VALUES (1157, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:29.973289');
INSERT INTO "public"."launcher_download_log" VALUES (1158, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:29.99188');
INSERT INTO "public"."launcher_download_log" VALUES (1159, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:29.999546');
INSERT INTO "public"."launcher_download_log" VALUES (1160, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:30.016472');
INSERT INTO "public"."launcher_download_log" VALUES (1161, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:32.000653');
INSERT INTO "public"."launcher_download_log" VALUES (1162, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:32.020598');
INSERT INTO "public"."launcher_download_log" VALUES (1163, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:59.511229');
INSERT INTO "public"."launcher_download_log" VALUES (1164, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:59.548157');
INSERT INTO "public"."launcher_download_log" VALUES (1165, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:59.653437');
INSERT INTO "public"."launcher_download_log" VALUES (1166, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:40:59.654704');
INSERT INTO "public"."launcher_download_log" VALUES (1167, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:59.681441');
INSERT INTO "public"."launcher_download_log" VALUES (1168, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:40:59.681766');
INSERT INTO "public"."launcher_download_log" VALUES (1170, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:17.89353');
INSERT INTO "public"."launcher_download_log" VALUES (1171, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:17.990925');
INSERT INTO "public"."launcher_download_log" VALUES (1173, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:18.021598');
INSERT INTO "public"."launcher_download_log" VALUES (1180, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:54.586354');
INSERT INTO "public"."launcher_download_log" VALUES (1182, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:12.7376');
INSERT INTO "public"."launcher_download_log" VALUES (1184, '127.0.0.1', '', 'update_1.0.0.1.zip', 'update', 't', '2025-06-03 21:42:12.787491');
INSERT INTO "public"."launcher_download_log" VALUES (1185, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:21.897094');
INSERT INTO "public"."launcher_download_log" VALUES (1187, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:22.025638');
INSERT INTO "public"."launcher_download_log" VALUES (1189, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:22.055752');
INSERT INTO "public"."launcher_download_log" VALUES (1192, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:56.568834');
INSERT INTO "public"."launcher_download_log" VALUES (1193, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:56.585889');
INSERT INTO "public"."launcher_download_log" VALUES (1196, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:58.591833');
INSERT INTO "public"."launcher_download_log" VALUES (1198, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:05.564578');
INSERT INTO "public"."launcher_download_log" VALUES (1200, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:13.412324');
INSERT INTO "public"."launcher_download_log" VALUES (1203, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:26.578414');
INSERT INTO "public"."launcher_download_log" VALUES (1204, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:26.595709');
INSERT INTO "public"."launcher_download_log" VALUES (1206, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:28.5987');
INSERT INTO "public"."launcher_download_log" VALUES (1207, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:56.574968');
INSERT INTO "public"."launcher_download_log" VALUES (1208, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:56.592664');
INSERT INTO "public"."launcher_download_log" VALUES (1211, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:58.595975');
INSERT INTO "public"."launcher_download_log" VALUES (1215, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:28.615273');
INSERT INTO "public"."launcher_download_log" VALUES (1216, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:28.630106');
INSERT INTO "public"."launcher_download_log" VALUES (1218, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:30.643275');
INSERT INTO "public"."launcher_download_log" VALUES (1220, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:44.623875');
INSERT INTO "public"."launcher_download_log" VALUES (1223, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:56.602443');
INSERT INTO "public"."launcher_download_log" VALUES (1224, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:56.618485');
INSERT INTO "public"."launcher_download_log" VALUES (1225, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:58.605147');
INSERT INTO "public"."launcher_download_log" VALUES (1227, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:09.681467');
INSERT INTO "public"."launcher_download_log" VALUES (1229, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:26.568985');
INSERT INTO "public"."launcher_download_log" VALUES (1231, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:26.594096');
INSERT INTO "public"."launcher_download_log" VALUES (1232, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:26.61401');
INSERT INTO "public"."launcher_download_log" VALUES (1234, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:28.630792');
INSERT INTO "public"."launcher_download_log" VALUES (1239, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:58.581733');
INSERT INTO "public"."launcher_download_log" VALUES (1241, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:16.024892');
INSERT INTO "public"."launcher_download_log" VALUES (1243, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:28.605765');
INSERT INTO "public"."launcher_download_log" VALUES (1244, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:28.624355');
INSERT INTO "public"."launcher_download_log" VALUES (1245, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:28.643516');
INSERT INTO "public"."launcher_download_log" VALUES (1246, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:28.655767');
INSERT INTO "public"."launcher_download_log" VALUES (1247, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:30.621101');
INSERT INTO "public"."launcher_download_log" VALUES (1249, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:56.570362');
INSERT INTO "public"."launcher_download_log" VALUES (1250, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:56.587734');
INSERT INTO "public"."launcher_download_log" VALUES (1252, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:56.609733');
INSERT INTO "public"."launcher_download_log" VALUES (1254, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:58.620203');
INSERT INTO "public"."launcher_download_log" VALUES (1472, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:10.745627');
INSERT INTO "public"."launcher_download_log" VALUES (1474, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:10.982293');
INSERT INTO "public"."launcher_download_log" VALUES (1476, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:11.044254');
INSERT INTO "public"."launcher_download_log" VALUES (1477, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:45.395365');
INSERT INTO "public"."launcher_download_log" VALUES (1478, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:07:45.435049');
INSERT INTO "public"."launcher_download_log" VALUES (1480, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:45.489703');
INSERT INTO "public"."launcher_download_log" VALUES (1482, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:07:47.486904');
INSERT INTO "public"."launcher_download_log" VALUES (1483, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:15.371353');
INSERT INTO "public"."launcher_download_log" VALUES (1484, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:15.404713');
INSERT INTO "public"."launcher_download_log" VALUES (1487, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:08:17.418018');
INSERT INTO "public"."launcher_download_log" VALUES (1491, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:45.372685');
INSERT INTO "public"."launcher_download_log" VALUES (1492, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:45.396065');
INSERT INTO "public"."launcher_download_log" VALUES (1494, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:08:47.450568');
INSERT INTO "public"."launcher_download_log" VALUES (1495, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:14.388024');
INSERT INTO "public"."launcher_download_log" VALUES (1498, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:14.606906');
INSERT INTO "public"."launcher_download_log" VALUES (1499, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:14.682625');
INSERT INTO "public"."launcher_download_log" VALUES (1774, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:37:36.34763');
INSERT INTO "public"."launcher_download_log" VALUES (1776, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:37:36.399612');
INSERT INTO "public"."launcher_download_log" VALUES (1777, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:37:36.432575');
INSERT INTO "public"."launcher_download_log" VALUES (1779, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:39:21.230457');
INSERT INTO "public"."launcher_download_log" VALUES (1781, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:39:21.274267');
INSERT INTO "public"."launcher_download_log" VALUES (1788, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:00.442958');
INSERT INTO "public"."launcher_download_log" VALUES (1790, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:00.483033');
INSERT INTO "public"."launcher_download_log" VALUES (1791, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:49.689796');
INSERT INTO "public"."launcher_download_log" VALUES (1794, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:49.946051');
INSERT INTO "public"."launcher_download_log" VALUES (1796, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:49.988359');
INSERT INTO "public"."launcher_download_log" VALUES (1797, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:41:58.397378');
INSERT INTO "public"."launcher_download_log" VALUES (1798, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:41:58.442465');
INSERT INTO "public"."launcher_download_log" VALUES (1803, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:42:12.372075');
INSERT INTO "public"."launcher_download_log" VALUES (1806, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:42:12.669692');
INSERT INTO "public"."launcher_download_log" VALUES (1808, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:42:12.702553');
INSERT INTO "public"."launcher_download_log" VALUES (1809, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:42:47.052843');
INSERT INTO "public"."launcher_download_log" VALUES (1810, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:42:47.078601');
INSERT INTO "public"."launcher_download_log" VALUES (1813, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:43:27.390538');
INSERT INTO "public"."launcher_download_log" VALUES (1819, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:44:02.064394');
INSERT INTO "public"."launcher_download_log" VALUES (1826, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:44:32.04065');
INSERT INTO "public"."launcher_download_log" VALUES (1828, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:44:32.103205');
INSERT INTO "public"."launcher_download_log" VALUES (2011, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:05.77975');
INSERT INTO "public"."launcher_download_log" VALUES (2012, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:05.830149');
INSERT INTO "public"."launcher_download_log" VALUES (2013, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:06.340484');
INSERT INTO "public"."launcher_download_log" VALUES (2014, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:06.371765');
INSERT INTO "public"."launcher_download_log" VALUES (2015, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:06.684994');
INSERT INTO "public"."launcher_download_log" VALUES (2016, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:06.715242');
INSERT INTO "public"."launcher_download_log" VALUES (2017, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:41.047911');
INSERT INTO "public"."launcher_download_log" VALUES (2018, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:41.07852');
INSERT INTO "public"."launcher_download_log" VALUES (2019, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:41.45534');
INSERT INTO "public"."launcher_download_log" VALUES (2020, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:41.482468');
INSERT INTO "public"."launcher_download_log" VALUES (2021, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:05:43.87811');
INSERT INTO "public"."launcher_download_log" VALUES (2022, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:05:43.906779');
INSERT INTO "public"."launcher_download_log" VALUES (2023, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:06:06.898638');
INSERT INTO "public"."launcher_download_log" VALUES (2024, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:06:06.935517');
INSERT INTO "public"."launcher_download_log" VALUES (2025, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:06:41.045755');
INSERT INTO "public"."launcher_download_log" VALUES (2026, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:06:41.077803');
INSERT INTO "public"."launcher_download_log" VALUES (2027, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:06:41.448271');
INSERT INTO "public"."launcher_download_log" VALUES (2028, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:06:41.4786');
INSERT INTO "public"."launcher_download_log" VALUES (2029, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:06:43.842726');
INSERT INTO "public"."launcher_download_log" VALUES (2030, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:06:43.868318');
INSERT INTO "public"."launcher_download_log" VALUES (2031, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:07:08.510532');
INSERT INTO "public"."launcher_download_log" VALUES (1169, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:17.854754');
INSERT INTO "public"."launcher_download_log" VALUES (1172, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:17.993826');
INSERT INTO "public"."launcher_download_log" VALUES (1174, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:18.023542');
INSERT INTO "public"."launcher_download_log" VALUES (1175, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:30.617113');
INSERT INTO "public"."launcher_download_log" VALUES (1176, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:52.541673');
INSERT INTO "public"."launcher_download_log" VALUES (1177, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:41:52.557862');
INSERT INTO "public"."launcher_download_log" VALUES (1178, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:52.567051');
INSERT INTO "public"."launcher_download_log" VALUES (1179, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:52.580748');
INSERT INTO "public"."launcher_download_log" VALUES (1181, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:41:54.606342');
INSERT INTO "public"."launcher_download_log" VALUES (1183, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:12.75778');
INSERT INTO "public"."launcher_download_log" VALUES (1186, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:21.941448');
INSERT INTO "public"."launcher_download_log" VALUES (1188, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:42:22.026019');
INSERT INTO "public"."launcher_download_log" VALUES (1190, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:22.056076');
INSERT INTO "public"."launcher_download_log" VALUES (1191, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:51.459592');
INSERT INTO "public"."launcher_download_log" VALUES (1194, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:56.595582');
INSERT INTO "public"."launcher_download_log" VALUES (1195, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:56.610083');
INSERT INTO "public"."launcher_download_log" VALUES (1197, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:42:58.61243');
INSERT INTO "public"."launcher_download_log" VALUES (1199, '127.0.0.1', '', 'update_1.0.0.1.zip', 'update', 't', '2025-06-03 21:43:05.589315');
INSERT INTO "public"."launcher_download_log" VALUES (1201, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:26.550652');
INSERT INTO "public"."launcher_download_log" VALUES (1202, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:26.57054');
INSERT INTO "public"."launcher_download_log" VALUES (1205, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:43:28.578785');
INSERT INTO "public"."launcher_download_log" VALUES (1209, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:56.599599');
INSERT INTO "public"."launcher_download_log" VALUES (1210, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:56.616064');
INSERT INTO "public"."launcher_download_log" VALUES (1212, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:43:58.616142');
INSERT INTO "public"."launcher_download_log" VALUES (1213, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:28.590946');
INSERT INTO "public"."launcher_download_log" VALUES (1214, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:28.608007');
INSERT INTO "public"."launcher_download_log" VALUES (1217, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:30.621188');
INSERT INTO "public"."launcher_download_log" VALUES (1219, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:44.596801');
INSERT INTO "public"."launcher_download_log" VALUES (1221, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:56.575273');
INSERT INTO "public"."launcher_download_log" VALUES (1222, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:44:56.593713');
INSERT INTO "public"."launcher_download_log" VALUES (1226, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:44:58.626372');
INSERT INTO "public"."launcher_download_log" VALUES (1228, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:09.70099');
INSERT INTO "public"."launcher_download_log" VALUES (1230, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:26.590379');
INSERT INTO "public"."launcher_download_log" VALUES (1233, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:28.610452');
INSERT INTO "public"."launcher_download_log" VALUES (1235, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:56.551839');
INSERT INTO "public"."launcher_download_log" VALUES (1236, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:45:56.56917');
INSERT INTO "public"."launcher_download_log" VALUES (1237, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:56.579036');
INSERT INTO "public"."launcher_download_log" VALUES (1238, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:56.591');
INSERT INTO "public"."launcher_download_log" VALUES (1240, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:45:58.602985');
INSERT INTO "public"."launcher_download_log" VALUES (1242, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:16.044682');
INSERT INTO "public"."launcher_download_log" VALUES (1248, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:30.643192');
INSERT INTO "public"."launcher_download_log" VALUES (1251, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-03 21:46:56.595572');
INSERT INTO "public"."launcher_download_log" VALUES (1253, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-03 21:46:58.599741');
INSERT INTO "public"."launcher_download_log" VALUES (1501, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:14:44.651001');
INSERT INTO "public"."launcher_download_log" VALUES (1505, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:51.073129');
INSERT INTO "public"."launcher_download_log" VALUES (1506, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:51.100124');
INSERT INTO "public"."launcher_download_log" VALUES (1508, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:14:53.147881');
INSERT INTO "public"."launcher_download_log" VALUES (1510, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:18:34.793283');
INSERT INTO "public"."launcher_download_log" VALUES (1515, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:09.303966');
INSERT INTO "public"."launcher_download_log" VALUES (1523, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:39.368826');
INSERT INTO "public"."launcher_download_log" VALUES (1524, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:39.39007');
INSERT INTO "public"."launcher_download_log" VALUES (1525, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:19:41.348371');
INSERT INTO "public"."launcher_download_log" VALUES (1526, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 20:19:41.376895');
INSERT INTO "public"."launcher_download_log" VALUES (1527, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 20:20:09.286122');
INSERT INTO "public"."launcher_download_log" VALUES (1537, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:03:12.870672');
INSERT INTO "public"."launcher_download_log" VALUES (1538, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:03:12.900076');
INSERT INTO "public"."launcher_download_log" VALUES (1547, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:17.680297');
INSERT INTO "public"."launcher_download_log" VALUES (1548, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:17.710172');
INSERT INTO "public"."launcher_download_log" VALUES (1549, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:20.068007');
INSERT INTO "public"."launcher_download_log" VALUES (1550, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:20.096554');
INSERT INTO "public"."launcher_download_log" VALUES (1551, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 21:04:47.086624');
INSERT INTO "public"."launcher_download_log" VALUES (1552, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 21:04:47.112357');
INSERT INTO "public"."launcher_download_log" VALUES (1783, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:39:21.287123');
INSERT INTO "public"."launcher_download_log" VALUES (1784, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:39:21.318076');
INSERT INTO "public"."launcher_download_log" VALUES (1787, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:00.442493');
INSERT INTO "public"."launcher_download_log" VALUES (1789, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:40:00.482568');
INSERT INTO "public"."launcher_download_log" VALUES (1793, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:40:49.938906');
INSERT INTO "public"."launcher_download_log" VALUES (1799, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:41:58.615211');
INSERT INTO "public"."launcher_download_log" VALUES (1801, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:41:58.646832');
INSERT INTO "public"."launcher_download_log" VALUES (1804, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:42:12.437257');
INSERT INTO "public"."launcher_download_log" VALUES (1807, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:42:12.682157');
INSERT INTO "public"."launcher_download_log" VALUES (1814, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:43:27.441394');
INSERT INTO "public"."launcher_download_log" VALUES (1816, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:43:27.687515');
INSERT INTO "public"."launcher_download_log" VALUES (1818, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:43:27.763467');
INSERT INTO "public"."launcher_download_log" VALUES (1820, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:44:02.11657');
INSERT INTO "public"."launcher_download_log" VALUES (1822, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:44:02.154412');
INSERT INTO "public"."launcher_download_log" VALUES (1823, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:44:04.123752');
INSERT INTO "public"."launcher_download_log" VALUES (1824, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:44:04.1584');
INSERT INTO "public"."launcher_download_log" VALUES (1825, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-04 23:44:32.04029');
INSERT INTO "public"."launcher_download_log" VALUES (1827, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-04 23:44:32.102722');
INSERT INTO "public"."launcher_download_log" VALUES (2032, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:07:08.548417');
INSERT INTO "public"."launcher_download_log" VALUES (2033, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:07:41.038435');
INSERT INTO "public"."launcher_download_log" VALUES (2034, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:07:41.069091');
INSERT INTO "public"."launcher_download_log" VALUES (2035, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:07:41.446376');
INSERT INTO "public"."launcher_download_log" VALUES (2036, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:07:41.477639');
INSERT INTO "public"."launcher_download_log" VALUES (2037, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:07:43.863007');
INSERT INTO "public"."launcher_download_log" VALUES (2038, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:07:43.89132');
INSERT INTO "public"."launcher_download_log" VALUES (2039, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:08:26.846302');
INSERT INTO "public"."launcher_download_log" VALUES (2040, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:08:26.907715');
INSERT INTO "public"."launcher_download_log" VALUES (2041, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:08:27.396803');
INSERT INTO "public"."launcher_download_log" VALUES (2042, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:08:27.451144');
INSERT INTO "public"."launcher_download_log" VALUES (2043, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:08:27.723723');
INSERT INTO "public"."launcher_download_log" VALUES (2044, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:08:27.77548');
INSERT INTO "public"."launcher_download_log" VALUES (2045, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:07.324529');
INSERT INTO "public"."launcher_download_log" VALUES (2047, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:07.905467');
INSERT INTO "public"."launcher_download_log" VALUES (2049, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:08.282722');
INSERT INTO "public"."launcher_download_log" VALUES (2051, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:12:42.810257');
INSERT INTO "public"."launcher_download_log" VALUES (2054, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:43.255938');
INSERT INTO "public"."launcher_download_log" VALUES (2056, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:12:45.679817');
INSERT INTO "public"."launcher_download_log" VALUES (2057, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 02:13:12.776163');
INSERT INTO "public"."launcher_download_log" VALUES (2060, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:13.211081');
INSERT INTO "public"."launcher_download_log" VALUES (2062, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 02:13:15.63146');
INSERT INTO "public"."launcher_download_log" VALUES (2246, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:02.19971');
INSERT INTO "public"."launcher_download_log" VALUES (2248, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:12.816451');
INSERT INTO "public"."launcher_download_log" VALUES (2251, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:13.080382');
INSERT INTO "public"."launcher_download_log" VALUES (2255, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:47.545556');
INSERT INTO "public"."launcher_download_log" VALUES (2257, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:49.33121');
INSERT INTO "public"."launcher_download_log" VALUES (2259, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:17.228121');
INSERT INTO "public"."launcher_download_log" VALUES (2260, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:17.25115');
INSERT INTO "public"."launcher_download_log" VALUES (2262, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:17.497127');
INSERT INTO "public"."launcher_download_log" VALUES (2264, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:19.573398');
INSERT INTO "public"."launcher_download_log" VALUES (2267, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:47.470839');
INSERT INTO "public"."launcher_download_log" VALUES (2269, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:49.275481');
INSERT INTO "public"."launcher_download_log" VALUES (2271, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:14:51.586081');
INSERT INTO "public"."launcher_download_log" VALUES (2272, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:14:51.843008');
INSERT INTO "public"."launcher_download_log" VALUES (2283, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:16:03.936851');
INSERT INTO "public"."launcher_download_log" VALUES (2789, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:19:29.63071');
INSERT INTO "public"."launcher_download_log" VALUES (2791, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:19:29.928686');
INSERT INTO "public"."launcher_download_log" VALUES (2793, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:19:30.613198');
INSERT INTO "public"."launcher_download_log" VALUES (2795, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:20:01.723834');
INSERT INTO "public"."launcher_download_log" VALUES (2796, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:20:01.731799');
INSERT INTO "public"."launcher_download_log" VALUES (2797, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:20:02.026279');
INSERT INTO "public"."launcher_download_log" VALUES (2799, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:20:02.717766');
INSERT INTO "public"."launcher_download_log" VALUES (2801, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:21:07.855712');
INSERT INTO "public"."launcher_download_log" VALUES (2803, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:21:08.115321');
INSERT INTO "public"."launcher_download_log" VALUES (2805, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:21:08.847102');
INSERT INTO "public"."launcher_download_log" VALUES (2808, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:24:27.568563');
INSERT INTO "public"."launcher_download_log" VALUES (2810, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:24:27.830088');
INSERT INTO "public"."launcher_download_log" VALUES (2812, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:24:28.757521');
INSERT INTO "public"."launcher_download_log" VALUES (2813, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:25:03.642143');
INSERT INTO "public"."launcher_download_log" VALUES (2815, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:25:03.896131');
INSERT INTO "public"."launcher_download_log" VALUES (2818, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:25:05.925302');
INSERT INTO "public"."launcher_download_log" VALUES (2819, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:03.673461');
INSERT INTO "public"."launcher_download_log" VALUES (2821, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:03.908005');
INSERT INTO "public"."launcher_download_log" VALUES (2824, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:05.921382');
INSERT INTO "public"."launcher_download_log" VALUES (2825, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:20.54268');
INSERT INTO "public"."launcher_download_log" VALUES (2827, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:20.803652');
INSERT INTO "public"."launcher_download_log" VALUES (2829, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:21.56333');
INSERT INTO "public"."launcher_download_log" VALUES (2833, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:28:26.936808');
INSERT INTO "public"."launcher_download_log" VALUES (2836, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:28:28.935805');
INSERT INTO "public"."launcher_download_log" VALUES (2247, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:12.593715');
INSERT INTO "public"."launcher_download_log" VALUES (2249, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:12.816869');
INSERT INTO "public"."launcher_download_log" VALUES (2250, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:12.861682');
INSERT INTO "public"."launcher_download_log" VALUES (2252, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:13.080917');
INSERT INTO "public"."launcher_download_log" VALUES (2253, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:47.301486');
INSERT INTO "public"."launcher_download_log" VALUES (2254, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:07:47.3238');
INSERT INTO "public"."launcher_download_log" VALUES (2256, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:47.561959');
INSERT INTO "public"."launcher_download_log" VALUES (2258, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:07:49.579096');
INSERT INTO "public"."launcher_download_log" VALUES (2261, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:17.481341');
INSERT INTO "public"."launcher_download_log" VALUES (2263, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:19.314899');
INSERT INTO "public"."launcher_download_log" VALUES (2265, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:47.22211');
INSERT INTO "public"."launcher_download_log" VALUES (2266, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:08:47.255931');
INSERT INTO "public"."launcher_download_log" VALUES (2268, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:47.501602');
INSERT INTO "public"."launcher_download_log" VALUES (2270, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:08:49.56332');
INSERT INTO "public"."launcher_download_log" VALUES (2273, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:14:51.871933');
INSERT INTO "public"."launcher_download_log" VALUES (2274, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:14:51.92077');
INSERT INTO "public"."launcher_download_log" VALUES (2275, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:14:52.118832');
INSERT INTO "public"."launcher_download_log" VALUES (2276, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:14:52.16261');
INSERT INTO "public"."launcher_download_log" VALUES (2277, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:15:26.27781');
INSERT INTO "public"."launcher_download_log" VALUES (2278, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:15:26.297124');
INSERT INTO "public"."launcher_download_log" VALUES (2279, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:15:26.527549');
INSERT INTO "public"."launcher_download_log" VALUES (2280, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:15:26.543744');
INSERT INTO "public"."launcher_download_log" VALUES (2281, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:15:28.327583');
INSERT INTO "public"."launcher_download_log" VALUES (2282, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:15:28.570815');
INSERT INTO "public"."launcher_download_log" VALUES (2284, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:16:04.352603');
INSERT INTO "public"."launcher_download_log" VALUES (2285, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:04.697575');
INSERT INTO "public"."launcher_download_log" VALUES (2286, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:04.946366');
INSERT INTO "public"."launcher_download_log" VALUES (2287, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:04.946712');
INSERT INTO "public"."launcher_download_log" VALUES (2288, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:04.997245');
INSERT INTO "public"."launcher_download_log" VALUES (2289, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:05.225354');
INSERT INTO "public"."launcher_download_log" VALUES (2290, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:05.226086');
INSERT INTO "public"."launcher_download_log" VALUES (2291, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:39.371167');
INSERT INTO "public"."launcher_download_log" VALUES (2292, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:39.390724');
INSERT INTO "public"."launcher_download_log" VALUES (2293, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:39.610576');
INSERT INTO "public"."launcher_download_log" VALUES (2294, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:39.62781');
INSERT INTO "public"."launcher_download_log" VALUES (2295, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:41.409629');
INSERT INTO "public"."launcher_download_log" VALUES (2296, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:41.655343');
INSERT INTO "public"."launcher_download_log" VALUES (2297, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:52.601817');
INSERT INTO "public"."launcher_download_log" VALUES (2298, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:52.875174');
INSERT INTO "public"."launcher_download_log" VALUES (2299, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:52.876201');
INSERT INTO "public"."launcher_download_log" VALUES (2300, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:17:52.878223');
INSERT INTO "public"."launcher_download_log" VALUES (2301, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:53.139111');
INSERT INTO "public"."launcher_download_log" VALUES (2302, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:17:53.139554');
INSERT INTO "public"."launcher_download_log" VALUES (2303, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:18:29.045088');
INSERT INTO "public"."launcher_download_log" VALUES (2304, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:18:29.304272');
INSERT INTO "public"."launcher_download_log" VALUES (2305, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:18:29.331592');
INSERT INTO "public"."launcher_download_log" VALUES (2306, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:18:29.337997');
INSERT INTO "public"."launcher_download_log" VALUES (2307, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:18:29.567317');
INSERT INTO "public"."launcher_download_log" VALUES (2308, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:18:29.581583');
INSERT INTO "public"."launcher_download_log" VALUES (2309, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:03.690834');
INSERT INTO "public"."launcher_download_log" VALUES (2310, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:03.713629');
INSERT INTO "public"."launcher_download_log" VALUES (2311, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:03.963937');
INSERT INTO "public"."launcher_download_log" VALUES (2312, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:03.964263');
INSERT INTO "public"."launcher_download_log" VALUES (2313, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:05.744439');
INSERT INTO "public"."launcher_download_log" VALUES (2314, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:06.005874');
INSERT INTO "public"."launcher_download_log" VALUES (2315, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:33.762854');
INSERT INTO "public"."launcher_download_log" VALUES (2316, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:33.816556');
INSERT INTO "public"."launcher_download_log" VALUES (2317, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:34.005113');
INSERT INTO "public"."launcher_download_log" VALUES (2318, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:34.052168');
INSERT INTO "public"."launcher_download_log" VALUES (2319, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:19:35.819991');
INSERT INTO "public"."launcher_download_log" VALUES (2320, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:19:36.067013');
INSERT INTO "public"."launcher_download_log" VALUES (2321, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:03.708831');
INSERT INTO "public"."launcher_download_log" VALUES (2322, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:03.74461');
INSERT INTO "public"."launcher_download_log" VALUES (2323, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:03.952697');
INSERT INTO "public"."launcher_download_log" VALUES (2324, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:03.977318');
INSERT INTO "public"."launcher_download_log" VALUES (2325, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:05.767748');
INSERT INTO "public"."launcher_download_log" VALUES (2326, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:06.013053');
INSERT INTO "public"."launcher_download_log" VALUES (2327, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:36.516564');
INSERT INTO "public"."launcher_download_log" VALUES (2328, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:36.760397');
INSERT INTO "public"."launcher_download_log" VALUES (2329, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:20:36.760739');
INSERT INTO "public"."launcher_download_log" VALUES (2330, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:36.830359');
INSERT INTO "public"."launcher_download_log" VALUES (2331, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:37.075544');
INSERT INTO "public"."launcher_download_log" VALUES (2332, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:20:37.075919');
INSERT INTO "public"."launcher_download_log" VALUES (2333, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:21:32.191403');
INSERT INTO "public"."launcher_download_log" VALUES (2334, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:21:32.489934');
INSERT INTO "public"."launcher_download_log" VALUES (2335, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:21:32.520186');
INSERT INTO "public"."launcher_download_log" VALUES (2336, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 03:21:32.527625');
INSERT INTO "public"."launcher_download_log" VALUES (2337, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:21:32.764793');
INSERT INTO "public"."launcher_download_log" VALUES (2338, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 03:21:32.765235');
INSERT INTO "public"."launcher_download_log" VALUES (2339, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:26:50.73109');
INSERT INTO "public"."launcher_download_log" VALUES (2340, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:26:50.784248');
INSERT INTO "public"."launcher_download_log" VALUES (2341, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:26:50.909511');
INSERT INTO "public"."launcher_download_log" VALUES (2342, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:26:51.011744');
INSERT INTO "public"."launcher_download_log" VALUES (2343, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:26:51.03593');
INSERT INTO "public"."launcher_download_log" VALUES (2344, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:26:51.142566');
INSERT INTO "public"."launcher_download_log" VALUES (2345, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:29:30.852476');
INSERT INTO "public"."launcher_download_log" VALUES (2346, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:29:31.039609');
INSERT INTO "public"."launcher_download_log" VALUES (2347, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:29:31.041759');
INSERT INTO "public"."launcher_download_log" VALUES (2348, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:29:31.149553');
INSERT INTO "public"."launcher_download_log" VALUES (2349, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:29:31.32032');
INSERT INTO "public"."launcher_download_log" VALUES (2350, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:29:31.323028');
INSERT INTO "public"."launcher_download_log" VALUES (2351, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:30:05.442853');
INSERT INTO "public"."launcher_download_log" VALUES (2352, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:30:05.450267');
INSERT INTO "public"."launcher_download_log" VALUES (2353, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:30:58.133465');
INSERT INTO "public"."launcher_download_log" VALUES (2354, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:30:58.340465');
INSERT INTO "public"."launcher_download_log" VALUES (2355, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 18:30:58.355032');
INSERT INTO "public"."launcher_download_log" VALUES (2356, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:30:58.399492');
INSERT INTO "public"."launcher_download_log" VALUES (2357, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:30:58.582553');
INSERT INTO "public"."launcher_download_log" VALUES (2358, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 18:30:58.599811');
INSERT INTO "public"."launcher_download_log" VALUES (2359, '127.0.0.1', '', 'PBConfig.exe', 'PBConfig', 't', '2025-06-05 18:31:06.95278');
INSERT INTO "public"."launcher_download_log" VALUES (2360, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 20:51:45.867405');
INSERT INTO "public"."launcher_download_log" VALUES (2361, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 20:51:46.044438');
INSERT INTO "public"."launcher_download_log" VALUES (2362, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 20:51:46.125575');
INSERT INTO "public"."launcher_download_log" VALUES (2364, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-05 20:51:46.838209');
INSERT INTO "public"."launcher_download_log" VALUES (2790, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:19:29.701105');
INSERT INTO "public"."launcher_download_log" VALUES (2792, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:19:29.942208');
INSERT INTO "public"."launcher_download_log" VALUES (2794, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:19:30.840607');
INSERT INTO "public"."launcher_download_log" VALUES (2798, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:20:02.0267');
INSERT INTO "public"."launcher_download_log" VALUES (2800, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:20:02.953496');
INSERT INTO "public"."launcher_download_log" VALUES (2802, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:21:07.89746');
INSERT INTO "public"."launcher_download_log" VALUES (2804, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:21:08.132214');
INSERT INTO "public"."launcher_download_log" VALUES (2806, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:21:09.090942');
INSERT INTO "public"."launcher_download_log" VALUES (2807, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:24:27.538486');
INSERT INTO "public"."launcher_download_log" VALUES (2809, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:24:27.82975');
INSERT INTO "public"."launcher_download_log" VALUES (2811, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:24:28.528302');
INSERT INTO "public"."launcher_download_log" VALUES (2814, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:25:03.653558');
INSERT INTO "public"."launcher_download_log" VALUES (2816, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:25:03.896514');
INSERT INTO "public"."launcher_download_log" VALUES (2817, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:25:05.679744');
INSERT INTO "public"."launcher_download_log" VALUES (2820, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:03.675377');
INSERT INTO "public"."launcher_download_log" VALUES (2822, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:03.908336');
INSERT INTO "public"."launcher_download_log" VALUES (2823, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:05.691356');
INSERT INTO "public"."launcher_download_log" VALUES (2826, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:27:20.574582');
INSERT INTO "public"."launcher_download_log" VALUES (2828, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:20.804005');
INSERT INTO "public"."launcher_download_log" VALUES (2830, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:27:21.793089');
INSERT INTO "public"."launcher_download_log" VALUES (2831, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:28:26.689579');
INSERT INTO "public"."launcher_download_log" VALUES (2832, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:28:26.713685');
INSERT INTO "public"."launcher_download_log" VALUES (2834, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 21:28:26.951594');
INSERT INTO "public"."launcher_download_log" VALUES (2835, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 21:28:28.706519');
INSERT INTO "public"."launcher_download_log" VALUES (2363, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-05 20:51:46.29352');
INSERT INTO "public"."launcher_download_log" VALUES (2365, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:25:18.91809');
INSERT INTO "public"."launcher_download_log" VALUES (2366, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:25:18.960247');
INSERT INTO "public"."launcher_download_log" VALUES (2367, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:25:19.20584');
INSERT INTO "public"."launcher_download_log" VALUES (2368, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:25:19.206217');
INSERT INTO "public"."launcher_download_log" VALUES (2369, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:25:19.91023');
INSERT INTO "public"."launcher_download_log" VALUES (2370, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:25:20.135735');
INSERT INTO "public"."launcher_download_log" VALUES (2371, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:26:43.964448');
INSERT INTO "public"."launcher_download_log" VALUES (2372, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:26:43.965279');
INSERT INTO "public"."launcher_download_log" VALUES (2373, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:26:44.228322');
INSERT INTO "public"."launcher_download_log" VALUES (2374, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:26:44.228658');
INSERT INTO "public"."launcher_download_log" VALUES (2375, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:26:44.978924');
INSERT INTO "public"."launcher_download_log" VALUES (2376, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:26:45.215857');
INSERT INTO "public"."launcher_download_log" VALUES (2377, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:12.290857');
INSERT INTO "public"."launcher_download_log" VALUES (2378, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:12.291896');
INSERT INTO "public"."launcher_download_log" VALUES (2379, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:12.562078');
INSERT INTO "public"."launcher_download_log" VALUES (2380, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:12.562423');
INSERT INTO "public"."launcher_download_log" VALUES (2381, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:13.257315');
INSERT INTO "public"."launcher_download_log" VALUES (2382, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:13.51787');
INSERT INTO "public"."launcher_download_log" VALUES (2383, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:38.205539');
INSERT INTO "public"."launcher_download_log" VALUES (2384, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:38.206456');
INSERT INTO "public"."launcher_download_log" VALUES (2385, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:38.487349');
INSERT INTO "public"."launcher_download_log" VALUES (2386, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:38.487696');
INSERT INTO "public"."launcher_download_log" VALUES (2387, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:28:39.182557');
INSERT INTO "public"."launcher_download_log" VALUES (2388, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:28:39.413398');
INSERT INTO "public"."launcher_download_log" VALUES (2389, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:21.511411');
INSERT INTO "public"."launcher_download_log" VALUES (2390, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:21.512233');
INSERT INTO "public"."launcher_download_log" VALUES (2391, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:21.770463');
INSERT INTO "public"."launcher_download_log" VALUES (2392, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:21.770821');
INSERT INTO "public"."launcher_download_log" VALUES (2393, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:22.47574');
INSERT INTO "public"."launcher_download_log" VALUES (2394, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:22.710851');
INSERT INTO "public"."launcher_download_log" VALUES (2395, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:42.008706');
INSERT INTO "public"."launcher_download_log" VALUES (2396, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:42.009524');
INSERT INTO "public"."launcher_download_log" VALUES (2397, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:42.282659');
INSERT INTO "public"."launcher_download_log" VALUES (2398, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:42.282983');
INSERT INTO "public"."launcher_download_log" VALUES (2399, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:30:42.996695');
INSERT INTO "public"."launcher_download_log" VALUES (2400, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:30:43.240778');
INSERT INTO "public"."launcher_download_log" VALUES (2401, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:31:26.228198');
INSERT INTO "public"."launcher_download_log" VALUES (2402, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:31:26.228526');
INSERT INTO "public"."launcher_download_log" VALUES (2403, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:31:26.493235');
INSERT INTO "public"."launcher_download_log" VALUES (2404, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:31:26.493559');
INSERT INTO "public"."launcher_download_log" VALUES (2405, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:31:27.203996');
INSERT INTO "public"."launcher_download_log" VALUES (2406, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:31:27.434303');
INSERT INTO "public"."launcher_download_log" VALUES (2407, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:14.409425');
INSERT INTO "public"."launcher_download_log" VALUES (2408, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:14.409761');
INSERT INTO "public"."launcher_download_log" VALUES (2409, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:14.668329');
INSERT INTO "public"."launcher_download_log" VALUES (2410, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:14.668686');
INSERT INTO "public"."launcher_download_log" VALUES (2411, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:15.346433');
INSERT INTO "public"."launcher_download_log" VALUES (2412, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:15.579457');
INSERT INTO "public"."launcher_download_log" VALUES (2413, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:43.753306');
INSERT INTO "public"."launcher_download_log" VALUES (2414, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:43.780708');
INSERT INTO "public"."launcher_download_log" VALUES (2415, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:44.03808');
INSERT INTO "public"."launcher_download_log" VALUES (2416, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:44.03841');
INSERT INTO "public"."launcher_download_log" VALUES (2417, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 03:35:44.749813');
INSERT INTO "public"."launcher_download_log" VALUES (2418, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 03:35:44.993407');
INSERT INTO "public"."launcher_download_log" VALUES (2419, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:49:58.1633');
INSERT INTO "public"."launcher_download_log" VALUES (2420, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:49:58.164771');
INSERT INTO "public"."launcher_download_log" VALUES (2421, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:49:58.437842');
INSERT INTO "public"."launcher_download_log" VALUES (2422, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:49:58.438172');
INSERT INTO "public"."launcher_download_log" VALUES (2423, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:49:59.137472');
INSERT INTO "public"."launcher_download_log" VALUES (2424, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:49:59.365635');
INSERT INTO "public"."launcher_download_log" VALUES (2425, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:50:43.149124');
INSERT INTO "public"."launcher_download_log" VALUES (2426, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:50:43.161057');
INSERT INTO "public"."launcher_download_log" VALUES (2427, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:50:43.407824');
INSERT INTO "public"."launcher_download_log" VALUES (2428, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:50:43.408143');
INSERT INTO "public"."launcher_download_log" VALUES (2429, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:50:44.16669');
INSERT INTO "public"."launcher_download_log" VALUES (2430, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:50:44.412132');
INSERT INTO "public"."launcher_download_log" VALUES (2431, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:19.321586');
INSERT INTO "public"."launcher_download_log" VALUES (2432, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:19.344029');
INSERT INTO "public"."launcher_download_log" VALUES (2433, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:19.556586');
INSERT INTO "public"."launcher_download_log" VALUES (2434, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:19.580795');
INSERT INTO "public"."launcher_download_log" VALUES (2435, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:21.3724');
INSERT INTO "public"."launcher_download_log" VALUES (2436, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:21.600673');
INSERT INTO "public"."launcher_download_log" VALUES (2437, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:54.074791');
INSERT INTO "public"."launcher_download_log" VALUES (2438, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:54.075103');
INSERT INTO "public"."launcher_download_log" VALUES (2439, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:54.336158');
INSERT INTO "public"."launcher_download_log" VALUES (2440, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:54.336533');
INSERT INTO "public"."launcher_download_log" VALUES (2441, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:51:55.064019');
INSERT INTO "public"."launcher_download_log" VALUES (2442, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:51:55.293084');
INSERT INTO "public"."launcher_download_log" VALUES (2443, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:52:30.148255');
INSERT INTO "public"."launcher_download_log" VALUES (2444, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:52:30.188923');
INSERT INTO "public"."launcher_download_log" VALUES (2445, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:52:30.407918');
INSERT INTO "public"."launcher_download_log" VALUES (2446, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:52:30.424152');
INSERT INTO "public"."launcher_download_log" VALUES (2447, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:52:32.188078');
INSERT INTO "public"."launcher_download_log" VALUES (2448, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:52:32.415628');
INSERT INTO "public"."launcher_download_log" VALUES (2449, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:00.112549');
INSERT INTO "public"."launcher_download_log" VALUES (2450, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:00.142224');
INSERT INTO "public"."launcher_download_log" VALUES (2451, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:00.355449');
INSERT INTO "public"."launcher_download_log" VALUES (2452, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:00.370449');
INSERT INTO "public"."launcher_download_log" VALUES (2453, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:02.137668');
INSERT INTO "public"."launcher_download_log" VALUES (2454, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:02.365903');
INSERT INTO "public"."launcher_download_log" VALUES (2455, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:30.14196');
INSERT INTO "public"."launcher_download_log" VALUES (2456, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:30.17178');
INSERT INTO "public"."launcher_download_log" VALUES (2457, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:30.379773');
INSERT INTO "public"."launcher_download_log" VALUES (2458, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:30.410768');
INSERT INTO "public"."launcher_download_log" VALUES (2459, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:53:32.211332');
INSERT INTO "public"."launcher_download_log" VALUES (2460, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:53:32.457616');
INSERT INTO "public"."launcher_download_log" VALUES (2461, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:54:00.108111');
INSERT INTO "public"."launcher_download_log" VALUES (2462, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:54:00.139524');
INSERT INTO "public"."launcher_download_log" VALUES (2463, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:54:00.352524');
INSERT INTO "public"."launcher_download_log" VALUES (2464, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:54:00.367001');
INSERT INTO "public"."launcher_download_log" VALUES (2465, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:54:02.147652');
INSERT INTO "public"."launcher_download_log" VALUES (2466, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:54:02.390613');
INSERT INTO "public"."launcher_download_log" VALUES (2468, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:57:51.610115');
INSERT INTO "public"."launcher_download_log" VALUES (2470, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:57:51.880995');
INSERT INTO "public"."launcher_download_log" VALUES (2472, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:57:52.867062');
INSERT INTO "public"."launcher_download_log" VALUES (2474, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:09:12.831611');
INSERT INTO "public"."launcher_download_log" VALUES (2476, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:09:13.095957');
INSERT INTO "public"."launcher_download_log" VALUES (2478, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:09:14.06667');
INSERT INTO "public"."launcher_download_log" VALUES (2479, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:12:16.609304');
INSERT INTO "public"."launcher_download_log" VALUES (2481, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:12:16.878708');
INSERT INTO "public"."launcher_download_log" VALUES (2483, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:12:17.594245');
INSERT INTO "public"."launcher_download_log" VALUES (2486, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:13:35.606599');
INSERT INTO "public"."launcher_download_log" VALUES (2488, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:13:35.85631');
INSERT INTO "public"."launcher_download_log" VALUES (2490, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:13:36.873084');
INSERT INTO "public"."launcher_download_log" VALUES (2491, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:34:09.971061');
INSERT INTO "public"."launcher_download_log" VALUES (2493, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:34:10.216571');
INSERT INTO "public"."launcher_download_log" VALUES (2495, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:34:10.957222');
INSERT INTO "public"."launcher_download_log" VALUES (2498, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:34:53.564284');
INSERT INTO "public"."launcher_download_log" VALUES (2500, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:34:53.814075');
INSERT INTO "public"."launcher_download_log" VALUES (2467, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:57:51.608596');
INSERT INTO "public"."launcher_download_log" VALUES (2469, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 04:57:51.88067');
INSERT INTO "public"."launcher_download_log" VALUES (2471, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 04:57:52.637571');
INSERT INTO "public"."launcher_download_log" VALUES (2473, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:09:12.831253');
INSERT INTO "public"."launcher_download_log" VALUES (2475, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:09:13.095611');
INSERT INTO "public"."launcher_download_log" VALUES (2477, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:09:13.820815');
INSERT INTO "public"."launcher_download_log" VALUES (2480, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:12:16.610167');
INSERT INTO "public"."launcher_download_log" VALUES (2482, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:12:16.879031');
INSERT INTO "public"."launcher_download_log" VALUES (2484, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:12:17.831887');
INSERT INTO "public"."launcher_download_log" VALUES (2485, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:13:35.605334');
INSERT INTO "public"."launcher_download_log" VALUES (2487, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:13:35.855992');
INSERT INTO "public"."launcher_download_log" VALUES (2489, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:13:36.632084');
INSERT INTO "public"."launcher_download_log" VALUES (2492, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:34:09.971377');
INSERT INTO "public"."launcher_download_log" VALUES (2494, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:34:10.216903');
INSERT INTO "public"."launcher_download_log" VALUES (2496, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:34:11.202603');
INSERT INTO "public"."launcher_download_log" VALUES (2497, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:34:53.545563');
INSERT INTO "public"."launcher_download_log" VALUES (2499, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:34:53.813756');
INSERT INTO "public"."launcher_download_log" VALUES (2501, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:35:56.384998');
INSERT INTO "public"."launcher_download_log" VALUES (2502, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:35:56.419694');
INSERT INTO "public"."launcher_download_log" VALUES (2503, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:35:56.643314');
INSERT INTO "public"."launcher_download_log" VALUES (2504, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:35:56.696104');
INSERT INTO "public"."launcher_download_log" VALUES (2505, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:35:57.337615');
INSERT INTO "public"."launcher_download_log" VALUES (2506, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:35:57.595776');
INSERT INTO "public"."launcher_download_log" VALUES (2507, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:36:32.391219');
INSERT INTO "public"."launcher_download_log" VALUES (2508, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:36:32.404559');
INSERT INTO "public"."launcher_download_log" VALUES (2509, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:36:32.657773');
INSERT INTO "public"."launcher_download_log" VALUES (2510, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:36:32.65811');
INSERT INTO "public"."launcher_download_log" VALUES (2511, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:36:34.415986');
INSERT INTO "public"."launcher_download_log" VALUES (2512, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:36:34.643266');
INSERT INTO "public"."launcher_download_log" VALUES (2513, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:37:25.231708');
INSERT INTO "public"."launcher_download_log" VALUES (2514, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:37:25.244881');
INSERT INTO "public"."launcher_download_log" VALUES (2515, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:37:25.492096');
INSERT INTO "public"."launcher_download_log" VALUES (2516, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:37:25.492428');
INSERT INTO "public"."launcher_download_log" VALUES (2517, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:37:26.208753');
INSERT INTO "public"."launcher_download_log" VALUES (2518, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:37:26.446171');
INSERT INTO "public"."launcher_download_log" VALUES (2519, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:01.344402');
INSERT INTO "public"."launcher_download_log" VALUES (2520, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:01.379191');
INSERT INTO "public"."launcher_download_log" VALUES (2521, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:01.584527');
INSERT INTO "public"."launcher_download_log" VALUES (2522, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:01.615872');
INSERT INTO "public"."launcher_download_log" VALUES (2523, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:03.375908');
INSERT INTO "public"."launcher_download_log" VALUES (2524, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:03.604955');
INSERT INTO "public"."launcher_download_log" VALUES (2525, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:31.240428');
INSERT INTO "public"."launcher_download_log" VALUES (2526, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:31.257316');
INSERT INTO "public"."launcher_download_log" VALUES (2527, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:31.478541');
INSERT INTO "public"."launcher_download_log" VALUES (2528, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:31.498464');
INSERT INTO "public"."launcher_download_log" VALUES (2529, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:38:33.31371');
INSERT INTO "public"."launcher_download_log" VALUES (2530, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:38:33.538482');
INSERT INTO "public"."launcher_download_log" VALUES (2531, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:01.253885');
INSERT INTO "public"."launcher_download_log" VALUES (2532, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:01.254372');
INSERT INTO "public"."launcher_download_log" VALUES (2533, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:01.504179');
INSERT INTO "public"."launcher_download_log" VALUES (2534, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:01.504588');
INSERT INTO "public"."launcher_download_log" VALUES (2535, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:03.281019');
INSERT INTO "public"."launcher_download_log" VALUES (2536, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:03.510749');
INSERT INTO "public"."launcher_download_log" VALUES (2537, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:31.291563');
INSERT INTO "public"."launcher_download_log" VALUES (2538, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:31.324908');
INSERT INTO "public"."launcher_download_log" VALUES (2539, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:31.529537');
INSERT INTO "public"."launcher_download_log" VALUES (2540, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:31.560654');
INSERT INTO "public"."launcher_download_log" VALUES (2541, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 05:39:33.313258');
INSERT INTO "public"."launcher_download_log" VALUES (2542, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 05:39:33.541735');
INSERT INTO "public"."launcher_download_log" VALUES (2543, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:01:13.113112');
INSERT INTO "public"."launcher_download_log" VALUES (2544, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:01:13.142552');
INSERT INTO "public"."launcher_download_log" VALUES (2545, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:01:13.359541');
INSERT INTO "public"."launcher_download_log" VALUES (2546, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:01:13.373963');
INSERT INTO "public"."launcher_download_log" VALUES (2547, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:01:14.137747');
INSERT INTO "public"."launcher_download_log" VALUES (2548, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:01:14.391717');
INSERT INTO "public"."launcher_download_log" VALUES (2549, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:08.885659');
INSERT INTO "public"."launcher_download_log" VALUES (2550, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:08.899258');
INSERT INTO "public"."launcher_download_log" VALUES (2551, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:09.120136');
INSERT INTO "public"."launcher_download_log" VALUES (2552, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:09.134465');
INSERT INTO "public"."launcher_download_log" VALUES (2553, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:09.874537');
INSERT INTO "public"."launcher_download_log" VALUES (2554, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:10.105991');
INSERT INTO "public"."launcher_download_log" VALUES (2555, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:44.985474');
INSERT INTO "public"."launcher_download_log" VALUES (2556, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:45.021476');
INSERT INTO "public"."launcher_download_log" VALUES (2557, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:45.223427');
INSERT INTO "public"."launcher_download_log" VALUES (2558, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:45.254203');
INSERT INTO "public"."launcher_download_log" VALUES (2559, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:04:47.016519');
INSERT INTO "public"."launcher_download_log" VALUES (2560, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:04:47.243779');
INSERT INTO "public"."launcher_download_log" VALUES (2561, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:14.998333');
INSERT INTO "public"."launcher_download_log" VALUES (2562, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:15.054945');
INSERT INTO "public"."launcher_download_log" VALUES (2563, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:15.265146');
INSERT INTO "public"."launcher_download_log" VALUES (2564, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:15.277585');
INSERT INTO "public"."launcher_download_log" VALUES (2565, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:17.035581');
INSERT INTO "public"."launcher_download_log" VALUES (2566, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:17.264398');
INSERT INTO "public"."launcher_download_log" VALUES (2567, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:44.970399');
INSERT INTO "public"."launcher_download_log" VALUES (2568, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:45.003377');
INSERT INTO "public"."launcher_download_log" VALUES (2569, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:45.199523');
INSERT INTO "public"."launcher_download_log" VALUES (2570, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:45.230945');
INSERT INTO "public"."launcher_download_log" VALUES (2571, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:05:47.009602');
INSERT INTO "public"."launcher_download_log" VALUES (2572, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:05:47.239577');
INSERT INTO "public"."launcher_download_log" VALUES (2573, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:14.980406');
INSERT INTO "public"."launcher_download_log" VALUES (2574, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:15.017949');
INSERT INTO "public"."launcher_download_log" VALUES (2575, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:15.2314');
INSERT INTO "public"."launcher_download_log" VALUES (2576, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:15.245707');
INSERT INTO "public"."launcher_download_log" VALUES (2577, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:17.02787');
INSERT INTO "public"."launcher_download_log" VALUES (2578, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:17.258083');
INSERT INTO "public"."launcher_download_log" VALUES (2579, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:45.021807');
INSERT INTO "public"."launcher_download_log" VALUES (2580, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:45.022169');
INSERT INTO "public"."launcher_download_log" VALUES (2581, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:45.260442');
INSERT INTO "public"."launcher_download_log" VALUES (2582, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:45.260782');
INSERT INTO "public"."launcher_download_log" VALUES (2583, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 06:06:47.049158');
INSERT INTO "public"."launcher_download_log" VALUES (2584, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 06:06:47.27884');
INSERT INTO "public"."launcher_download_log" VALUES (2585, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:03:12.007848');
INSERT INTO "public"."launcher_download_log" VALUES (2586, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:03:12.063168');
INSERT INTO "public"."launcher_download_log" VALUES (2588, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:03:12.290135');
INSERT INTO "public"."launcher_download_log" VALUES (2590, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:03:13.215738');
INSERT INTO "public"."launcher_download_log" VALUES (2587, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:03:12.269819');
INSERT INTO "public"."launcher_download_log" VALUES (2589, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:03:12.983327');
INSERT INTO "public"."launcher_download_log" VALUES (2591, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:07:22.744297');
INSERT INTO "public"."launcher_download_log" VALUES (2592, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:07:22.765531');
INSERT INTO "public"."launcher_download_log" VALUES (2593, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:07:23.003309');
INSERT INTO "public"."launcher_download_log" VALUES (2594, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:07:23.04404');
INSERT INTO "public"."launcher_download_log" VALUES (2595, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:07:23.724721');
INSERT INTO "public"."launcher_download_log" VALUES (2596, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:07:23.956297');
INSERT INTO "public"."launcher_download_log" VALUES (2597, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:09:28.9115');
INSERT INTO "public"."launcher_download_log" VALUES (2598, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:09:28.928674');
INSERT INTO "public"."launcher_download_log" VALUES (2599, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:09:29.175283');
INSERT INTO "public"."launcher_download_log" VALUES (2600, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:09:29.175631');
INSERT INTO "public"."launcher_download_log" VALUES (2601, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-07 16:09:30.933922');
INSERT INTO "public"."launcher_download_log" VALUES (2602, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-07 16:09:31.174226');
INSERT INTO "public"."launcher_download_log" VALUES (2603, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:21:46.351005');
INSERT INTO "public"."launcher_download_log" VALUES (2604, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:21:46.41798');
INSERT INTO "public"."launcher_download_log" VALUES (2605, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:21:46.608767');
INSERT INTO "public"."launcher_download_log" VALUES (2606, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:21:46.655672');
INSERT INTO "public"."launcher_download_log" VALUES (2607, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:21:47.292842');
INSERT INTO "public"."launcher_download_log" VALUES (2608, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:21:47.525339');
INSERT INTO "public"."launcher_download_log" VALUES (2609, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:22.438267');
INSERT INTO "public"."launcher_download_log" VALUES (2610, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:22.463159');
INSERT INTO "public"."launcher_download_log" VALUES (2611, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:22.677116');
INSERT INTO "public"."launcher_download_log" VALUES (2612, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:22.70882');
INSERT INTO "public"."launcher_download_log" VALUES (2613, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:24.458394');
INSERT INTO "public"."launcher_download_log" VALUES (2614, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:24.705855');
INSERT INTO "public"."launcher_download_log" VALUES (2615, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:54.379263');
INSERT INTO "public"."launcher_download_log" VALUES (2616, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:54.405652');
INSERT INTO "public"."launcher_download_log" VALUES (2617, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:54.612696');
INSERT INTO "public"."launcher_download_log" VALUES (2618, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:54.645499');
INSERT INTO "public"."launcher_download_log" VALUES (2619, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:22:56.41517');
INSERT INTO "public"."launcher_download_log" VALUES (2620, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:22:56.646947');
INSERT INTO "public"."launcher_download_log" VALUES (2621, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:23:22.350494');
INSERT INTO "public"."launcher_download_log" VALUES (2622, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:23:22.372789');
INSERT INTO "public"."launcher_download_log" VALUES (2623, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:23:22.590534');
INSERT INTO "public"."launcher_download_log" VALUES (2624, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:23:22.604514');
INSERT INTO "public"."launcher_download_log" VALUES (2625, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:23:24.38337');
INSERT INTO "public"."launcher_download_log" VALUES (2626, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:23:24.613334');
INSERT INTO "public"."launcher_download_log" VALUES (2627, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:55:23.181275');
INSERT INTO "public"."launcher_download_log" VALUES (2628, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:55:23.238594');
INSERT INTO "public"."launcher_download_log" VALUES (2629, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:55:23.434276');
INSERT INTO "public"."launcher_download_log" VALUES (2630, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:55:23.477729');
INSERT INTO "public"."launcher_download_log" VALUES (2631, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:55:24.152844');
INSERT INTO "public"."launcher_download_log" VALUES (2632, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:55:24.41075');
INSERT INTO "public"."launcher_download_log" VALUES (2633, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:55:59.240802');
INSERT INTO "public"."launcher_download_log" VALUES (2634, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:55:59.274088');
INSERT INTO "public"."launcher_download_log" VALUES (2635, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:55:59.494185');
INSERT INTO "public"."launcher_download_log" VALUES (2636, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:55:59.508295');
INSERT INTO "public"."launcher_download_log" VALUES (2637, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:56:01.262995');
INSERT INTO "public"."launcher_download_log" VALUES (2638, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:56:01.492961');
INSERT INTO "public"."launcher_download_log" VALUES (2639, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:17.739049');
INSERT INTO "public"."launcher_download_log" VALUES (2640, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:17.746498');
INSERT INTO "public"."launcher_download_log" VALUES (2641, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:18.019943');
INSERT INTO "public"."launcher_download_log" VALUES (2642, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:18.020284');
INSERT INTO "public"."launcher_download_log" VALUES (2643, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:18.721369');
INSERT INTO "public"."launcher_download_log" VALUES (2644, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:18.946941');
INSERT INTO "public"."launcher_download_log" VALUES (2645, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:53.893964');
INSERT INTO "public"."launcher_download_log" VALUES (2646, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:53.909501');
INSERT INTO "public"."launcher_download_log" VALUES (2647, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:54.125632');
INSERT INTO "public"."launcher_download_log" VALUES (2648, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:54.138686');
INSERT INTO "public"."launcher_download_log" VALUES (2649, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:57:55.917774');
INSERT INTO "public"."launcher_download_log" VALUES (2650, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:57:56.14716');
INSERT INTO "public"."launcher_download_log" VALUES (2651, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:23.798888');
INSERT INTO "public"."launcher_download_log" VALUES (2652, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:23.828196');
INSERT INTO "public"."launcher_download_log" VALUES (2653, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:24.038956');
INSERT INTO "public"."launcher_download_log" VALUES (2654, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:24.052904');
INSERT INTO "public"."launcher_download_log" VALUES (2655, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:25.837562');
INSERT INTO "public"."launcher_download_log" VALUES (2656, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:26.079215');
INSERT INTO "public"."launcher_download_log" VALUES (2657, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:53.865527');
INSERT INTO "public"."launcher_download_log" VALUES (2658, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:53.897855');
INSERT INTO "public"."launcher_download_log" VALUES (2659, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:54.138814');
INSERT INTO "public"."launcher_download_log" VALUES (2660, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:54.139157');
INSERT INTO "public"."launcher_download_log" VALUES (2661, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 01:58:55.900584');
INSERT INTO "public"."launcher_download_log" VALUES (2662, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 01:58:56.131746');
INSERT INTO "public"."launcher_download_log" VALUES (2663, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:01.885601');
INSERT INTO "public"."launcher_download_log" VALUES (2664, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:01.902069');
INSERT INTO "public"."launcher_download_log" VALUES (2665, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:02.162861');
INSERT INTO "public"."launcher_download_log" VALUES (2666, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:02.16322');
INSERT INTO "public"."launcher_download_log" VALUES (2667, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:02.856545');
INSERT INTO "public"."launcher_download_log" VALUES (2668, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:03.102529');
INSERT INTO "public"."launcher_download_log" VALUES (2669, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:38.038728');
INSERT INTO "public"."launcher_download_log" VALUES (2670, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:38.044721');
INSERT INTO "public"."launcher_download_log" VALUES (2671, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:38.295656');
INSERT INTO "public"."launcher_download_log" VALUES (2672, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:38.296024');
INSERT INTO "public"."launcher_download_log" VALUES (2673, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:05:40.072034');
INSERT INTO "public"."launcher_download_log" VALUES (2674, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:05:40.302081');
INSERT INTO "public"."launcher_download_log" VALUES (2675, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:07.977695');
INSERT INTO "public"."launcher_download_log" VALUES (2676, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:08.014207');
INSERT INTO "public"."launcher_download_log" VALUES (2677, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:08.216162');
INSERT INTO "public"."launcher_download_log" VALUES (2678, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:08.247202');
INSERT INTO "public"."launcher_download_log" VALUES (2679, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:10.023863');
INSERT INTO "public"."launcher_download_log" VALUES (2680, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:10.26149');
INSERT INTO "public"."launcher_download_log" VALUES (2681, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:38.045134');
INSERT INTO "public"."launcher_download_log" VALUES (2682, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:38.05281');
INSERT INTO "public"."launcher_download_log" VALUES (2683, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:38.289599');
INSERT INTO "public"."launcher_download_log" VALUES (2684, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:38.289987');
INSERT INTO "public"."launcher_download_log" VALUES (2685, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:06:40.083363');
INSERT INTO "public"."launcher_download_log" VALUES (2686, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:06:40.327029');
INSERT INTO "public"."launcher_download_log" VALUES (2687, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:07.916115');
INSERT INTO "public"."launcher_download_log" VALUES (2688, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:07.930323');
INSERT INTO "public"."launcher_download_log" VALUES (2689, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:08.150788');
INSERT INTO "public"."launcher_download_log" VALUES (2690, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:08.166071');
INSERT INTO "public"."launcher_download_log" VALUES (2691, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:09.926127');
INSERT INTO "public"."launcher_download_log" VALUES (2693, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:54.614781');
INSERT INTO "public"."launcher_download_log" VALUES (2695, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:54.896982');
INSERT INTO "public"."launcher_download_log" VALUES (2697, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:55.548633');
INSERT INTO "public"."launcher_download_log" VALUES (2701, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:08:30.8682');
INSERT INTO "public"."launcher_download_log" VALUES (2703, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:08:32.650169');
INSERT INTO "public"."launcher_download_log" VALUES (2707, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:09:00.911548');
INSERT INTO "public"."launcher_download_log" VALUES (2709, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:09:02.700676');
INSERT INTO "public"."launcher_download_log" VALUES (2712, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:09:30.670894');
INSERT INTO "public"."launcher_download_log" VALUES (2714, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:09:30.910747');
INSERT INTO "public"."launcher_download_log" VALUES (2692, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:10.157028');
INSERT INTO "public"."launcher_download_log" VALUES (2694, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:07:54.628134');
INSERT INTO "public"."launcher_download_log" VALUES (2696, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:54.897345');
INSERT INTO "public"."launcher_download_log" VALUES (2698, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:07:55.777566');
INSERT INTO "public"."launcher_download_log" VALUES (2699, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:08:30.637674');
INSERT INTO "public"."launcher_download_log" VALUES (2700, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:08:30.651812');
INSERT INTO "public"."launcher_download_log" VALUES (2702, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:08:30.881666');
INSERT INTO "public"."launcher_download_log" VALUES (2704, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:08:32.880862');
INSERT INTO "public"."launcher_download_log" VALUES (2705, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:09:00.667052');
INSERT INTO "public"."launcher_download_log" VALUES (2706, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:09:00.69237');
INSERT INTO "public"."launcher_download_log" VALUES (2708, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:09:00.925818');
INSERT INTO "public"."launcher_download_log" VALUES (2710, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:09:02.928852');
INSERT INTO "public"."launcher_download_log" VALUES (2711, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:09:30.650117');
INSERT INTO "public"."launcher_download_log" VALUES (2713, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:09:30.877637');
INSERT INTO "public"."launcher_download_log" VALUES (2715, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:26:24.182148');
INSERT INTO "public"."launcher_download_log" VALUES (2716, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:26:24.24097');
INSERT INTO "public"."launcher_download_log" VALUES (2717, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:26:24.445125');
INSERT INTO "public"."launcher_download_log" VALUES (2718, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:26:24.48844');
INSERT INTO "public"."launcher_download_log" VALUES (2719, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:26:25.171894');
INSERT INTO "public"."launcher_download_log" VALUES (2720, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:26:25.403807');
INSERT INTO "public"."launcher_download_log" VALUES (2721, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:00.232459');
INSERT INTO "public"."launcher_download_log" VALUES (2722, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:00.254378');
INSERT INTO "public"."launcher_download_log" VALUES (2723, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:00.464463');
INSERT INTO "public"."launcher_download_log" VALUES (2724, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:00.480007');
INSERT INTO "public"."launcher_download_log" VALUES (2725, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:02.258362');
INSERT INTO "public"."launcher_download_log" VALUES (2726, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:02.502478');
INSERT INTO "public"."launcher_download_log" VALUES (2727, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:30.223693');
INSERT INTO "public"."launcher_download_log" VALUES (2728, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:30.265238');
INSERT INTO "public"."launcher_download_log" VALUES (2729, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:30.480608');
INSERT INTO "public"."launcher_download_log" VALUES (2730, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:30.496298');
INSERT INTO "public"."launcher_download_log" VALUES (2731, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:32.241795');
INSERT INTO "public"."launcher_download_log" VALUES (2732, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:32.488446');
INSERT INTO "public"."launcher_download_log" VALUES (2733, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:52.199473');
INSERT INTO "public"."launcher_download_log" VALUES (2734, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:52.223433');
INSERT INTO "public"."launcher_download_log" VALUES (2735, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:52.450306');
INSERT INTO "public"."launcher_download_log" VALUES (2736, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:52.465978');
INSERT INTO "public"."launcher_download_log" VALUES (2737, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:27:53.187678');
INSERT INTO "public"."launcher_download_log" VALUES (2738, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:27:53.412781');
INSERT INTO "public"."launcher_download_log" VALUES (2739, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:28:28.264186');
INSERT INTO "public"."launcher_download_log" VALUES (2740, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:28:28.300051');
INSERT INTO "public"."launcher_download_log" VALUES (2741, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:28:28.523239');
INSERT INTO "public"."launcher_download_log" VALUES (2742, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:28:28.539613');
INSERT INTO "public"."launcher_download_log" VALUES (2743, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:28:30.27756');
INSERT INTO "public"."launcher_download_log" VALUES (2744, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:28:30.50651');
INSERT INTO "public"."launcher_download_log" VALUES (2745, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:28:58.253802');
INSERT INTO "public"."launcher_download_log" VALUES (2746, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:28:58.273378');
INSERT INTO "public"."launcher_download_log" VALUES (2747, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:28:58.496538');
INSERT INTO "public"."launcher_download_log" VALUES (2748, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:28:58.513458');
INSERT INTO "public"."launcher_download_log" VALUES (2749, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:00.275337');
INSERT INTO "public"."launcher_download_log" VALUES (2750, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:29:00.520558');
INSERT INTO "public"."launcher_download_log" VALUES (2751, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:28.297747');
INSERT INTO "public"."launcher_download_log" VALUES (2752, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:28.347415');
INSERT INTO "public"."launcher_download_log" VALUES (2753, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:29:28.567334');
INSERT INTO "public"."launcher_download_log" VALUES (2754, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:29:28.598574');
INSERT INTO "public"."launcher_download_log" VALUES (2755, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:30.321261');
INSERT INTO "public"."launcher_download_log" VALUES (2756, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:29:30.553122');
INSERT INTO "public"."launcher_download_log" VALUES (2757, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:58.242119');
INSERT INTO "public"."launcher_download_log" VALUES (2758, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:29:58.280856');
INSERT INTO "public"."launcher_download_log" VALUES (2759, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:18.660774');
INSERT INTO "public"."launcher_download_log" VALUES (2760, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:18.676477');
INSERT INTO "public"."launcher_download_log" VALUES (2761, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:18.907128');
INSERT INTO "public"."launcher_download_log" VALUES (2762, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:18.907461');
INSERT INTO "public"."launcher_download_log" VALUES (2763, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:19.653456');
INSERT INTO "public"."launcher_download_log" VALUES (2764, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:19.885838');
INSERT INTO "public"."launcher_download_log" VALUES (2765, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:54.733929');
INSERT INTO "public"."launcher_download_log" VALUES (2766, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:54.763393');
INSERT INTO "public"."launcher_download_log" VALUES (2767, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:54.980948');
INSERT INTO "public"."launcher_download_log" VALUES (2768, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:54.995319');
INSERT INTO "public"."launcher_download_log" VALUES (2769, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:31:56.763504');
INSERT INTO "public"."launcher_download_log" VALUES (2770, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:31:56.993036');
INSERT INTO "public"."launcher_download_log" VALUES (2771, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:32:24.734283');
INSERT INTO "public"."launcher_download_log" VALUES (2772, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:32:24.757272');
INSERT INTO "public"."launcher_download_log" VALUES (2773, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:32:24.979105');
INSERT INTO "public"."launcher_download_log" VALUES (2774, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:32:24.993158');
INSERT INTO "public"."launcher_download_log" VALUES (2775, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 02:32:26.756625');
INSERT INTO "public"."launcher_download_log" VALUES (2776, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 02:32:27.007981');
INSERT INTO "public"."launcher_download_log" VALUES (2777, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:29:00.944131');
INSERT INTO "public"."launcher_download_log" VALUES (2778, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:29:00.997687');
INSERT INTO "public"."launcher_download_log" VALUES (2779, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:29:01.203822');
INSERT INTO "public"."launcher_download_log" VALUES (2780, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:29:01.23336');
INSERT INTO "public"."launcher_download_log" VALUES (2781, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:29:01.928045');
INSERT INTO "public"."launcher_download_log" VALUES (2782, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:29:02.161044');
INSERT INTO "public"."launcher_download_log" VALUES (2783, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:30:06.97374');
INSERT INTO "public"."launcher_download_log" VALUES (2784, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:30:06.986485');
INSERT INTO "public"."launcher_download_log" VALUES (2785, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:30:07.221733');
INSERT INTO "public"."launcher_download_log" VALUES (2786, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:30:07.222104');
INSERT INTO "public"."launcher_download_log" VALUES (2787, '127.0.0.1', '', 'launcher_update', 'launcher_check', 't', '2025-06-08 03:30:09.003777');
INSERT INTO "public"."launcher_download_log" VALUES (2788, '127.0.0.1', '', 'update', 'update_check', 't', '2025-06-08 03:30:09.23793');

-- ----------------------------
-- Table structure for launcher_game_file
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_game_file";
CREATE TABLE "public"."launcher_game_file" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_game_file_id_seq'::regclass),
  "filename" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "relative_path" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "md5_hash" char(32) COLLATE "pg_catalog"."default" NOT NULL,
  "file_size" int8,
  "version_id" int4 NOT NULL,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON TABLE "public"."launcher_game_file" IS 'Archivos asociados a versiones del juego';

-- ----------------------------
-- Records of launcher_game_file
-- ----------------------------
INSERT INTO "public"."launcher_game_file" VALUES (6, '61AlyhAAEL._AC_UF8941000_QL80_.jpg', '61Al+yhAAEL._AC_UF894,1000_QL80_.jpg', 'eee33bf14c904b9b6aa0a5968c24e140', 58381, 6, '2025-06-05 00:32:15.375941', '2025-06-05 00:32:15.375944');

-- ----------------------------
-- Table structure for launcher_game_version
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_game_version";
CREATE TABLE "public"."launcher_game_version" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_game_version_id_seq'::regclass),
  "version" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "is_latest" bool DEFAULT false,
  "release_notes" text COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int4
)
;
COMMENT ON TABLE "public"."launcher_game_version" IS 'Versiones del juego';

-- ----------------------------
-- Records of launcher_game_version
-- ----------------------------
INSERT INTO "public"."launcher_game_version" VALUES (4, '1.0.0.0', 'f', '', '2025-05-28 19:51:28.815911', 1);
INSERT INTO "public"."launcher_game_version" VALUES (6, '1.0.0.1', 't', 'test', '2025-06-03 21:09:43.109026', 1);

-- ----------------------------
-- Table structure for launcher_news_message
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_news_message";
CREATE TABLE "public"."launcher_news_message" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_news_message_id_seq'::regclass),
  "type" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "message" text COLLATE "pg_catalog"."default" NOT NULL,
  "is_active" bool DEFAULT true,
  "priority" int4 DEFAULT 0,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int4
)
;
COMMENT ON TABLE "public"."launcher_news_message" IS 'Mensajes y noticias del launcher';

-- ----------------------------
-- Records of launcher_news_message
-- ----------------------------
INSERT INTO "public"."launcher_news_message" VALUES (21, 'Mantenimiento', 'Mantenimiento programado del servidor el [FECHA] de [HORA] a [HORA]. El juego no estará disponible durante este período.', 't', 5, '2025-06-08 17:42:43.95604', 1);
INSERT INTO "public"."launcher_news_message" VALUES (22, 'Evento', '¡Evento especial este fin de semana! Participa y gana recompensas exclusivas. No te pierdas esta oportunidad única.', 't', 4, '2025-06-08 17:45:12.497036', 1);

-- ----------------------------
-- Table structure for launcher_notification_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_notification_log";
CREATE TABLE "public"."launcher_notification_log" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_notification_log_id_seq'::regclass),
  "notification_type" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "title" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "message" text COLLATE "pg_catalog"."default" NOT NULL,
  "recipient" varchar(255) COLLATE "pg_catalog"."default",
  "status" varchar(50) COLLATE "pg_catalog"."default",
  "error_message" text COLLATE "pg_catalog"."default",
  "sent_at" timestamp(6),
  "created_at" timestamp(6)
)
;

-- ----------------------------
-- Records of launcher_notification_log
-- ----------------------------

-- ----------------------------
-- Table structure for launcher_server_settings
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_server_settings";
CREATE TABLE "public"."launcher_server_settings" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_server_settings_id_seq'::regclass),
  "key" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "value" text COLLATE "pg_catalog"."default" NOT NULL,
  "description" varchar(255) COLLATE "pg_catalog"."default",
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int4
)
;
COMMENT ON TABLE "public"."launcher_server_settings" IS 'Configuraciones del servidor';

-- ----------------------------
-- Records of launcher_server_settings
-- ----------------------------
INSERT INTO "public"."launcher_server_settings" VALUES (1, 'maintenance_mode', 'false', 'Modo de mantenimiento', '2025-05-28 19:42:09.792872', NULL);
INSERT INTO "public"."launcher_server_settings" VALUES (2, 'allow_registration', 'false', 'Permitir registro de usuarios', '2025-05-28 19:42:09.792876', NULL);
INSERT INTO "public"."launcher_server_settings" VALUES (3, 'max_file_size', '524288000', 'Tamaño máximo de archivo en bytes', '2025-05-28 19:42:09.792878', NULL);
INSERT INTO "public"."launcher_server_settings" VALUES (4, 'launcher_update_check_interval', '300', 'Intervalo de verificación de actualización del launcher (segundos)', '2025-05-28 19:42:09.792879', NULL);
INSERT INTO "public"."launcher_server_settings" VALUES (5, 'auto_backup_enabled', 'true', 'Backup automático habilitado', '2025-05-28 19:42:09.792881', NULL);
INSERT INTO "public"."launcher_server_settings" VALUES (6, 'log_retention_days', '30', 'Días de retención de logs', '2025-05-28 19:42:09.792882', NULL);

-- ----------------------------
-- Table structure for launcher_system_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_system_config";
CREATE TABLE "public"."launcher_system_config" (
  "id" int4 NOT NULL DEFAULT 1,
  "system_name" varchar(255) COLLATE "pg_catalog"."default" DEFAULT 'Launcher Admin Panel'::character varying,
  "admin_email" varchar(255) COLLATE "pg_catalog"."default" DEFAULT 'admin@localhost'::character varying,
  "timezone" varchar(100) COLLATE "pg_catalog"."default" DEFAULT 'America/Mexico_City'::character varying,
  "language" varchar(10) COLLATE "pg_catalog"."default" DEFAULT 'es'::character varying,
  "maintenance_mode" bool DEFAULT false,
  "maintenance_message" text COLLATE "pg_catalog"."default" DEFAULT 'Sistema en mantenimiento'::text,
  "debug_mode" bool DEFAULT false,
  "launcher_base_url" varchar(500) COLLATE "pg_catalog"."default" DEFAULT 'http://localhost:5000/Launcher'::character varying,
  "update_check_interval" int4 DEFAULT 300,
  "max_download_retries" int4 DEFAULT 3,
  "connection_timeout" int4 DEFAULT 30,
  "auto_update_enabled" bool DEFAULT true,
  "force_ssl" bool DEFAULT false,
  "proxy_enabled" bool DEFAULT false,
  "proxy_port" int4 DEFAULT 8080,
  "proxy_ip" varchar(255) COLLATE "pg_catalog"."default" DEFAULT '127.0.0.1'::character varying,
  "session_duration_hours" int4 DEFAULT 24,
  "max_login_attempts" int4 DEFAULT 5,
  "download_rate_limit" int4 DEFAULT 100,
  "ip_ban_duration_minutes" int4 DEFAULT 60,
  "rate_limiting_enabled" bool DEFAULT true,
  "log_all_requests" bool DEFAULT true,
  "ip_whitelist" text COLLATE "pg_catalog"."default",
  "webhook_url" varchar(500) COLLATE "pg_catalog"."default",
  "notification_email" varchar(255) COLLATE "pg_catalog"."default",
  "alert_level" varchar(50) COLLATE "pg_catalog"."default" DEFAULT 'errors_only'::character varying,
  "notify_new_versions" bool DEFAULT true,
  "notify_system_errors" bool DEFAULT true,
  "notify_high_traffic" bool DEFAULT false,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int4
)
;
COMMENT ON COLUMN "public"."launcher_system_config"."id" IS 'ID único de configuración';
COMMENT ON COLUMN "public"."launcher_system_config"."system_name" IS 'Nombre del sistema';
COMMENT ON COLUMN "public"."launcher_system_config"."admin_email" IS 'Email del administrador principal';
COMMENT ON COLUMN "public"."launcher_system_config"."timezone" IS 'Zona horaria del sistema';
COMMENT ON COLUMN "public"."launcher_system_config"."language" IS 'Idioma por defecto del sistema';
COMMENT ON COLUMN "public"."launcher_system_config"."maintenance_mode" IS 'Modo de mantenimiento activo/inactivo';
COMMENT ON COLUMN "public"."launcher_system_config"."maintenance_message" IS 'Mensaje mostrado durante mantenimiento';
COMMENT ON COLUMN "public"."launcher_system_config"."debug_mode" IS 'Modo de depuración activo/inactivo';
COMMENT ON COLUMN "public"."launcher_system_config"."launcher_base_url" IS 'URL base para descargas del launcher';
COMMENT ON COLUMN "public"."launcher_system_config"."update_check_interval" IS 'Intervalo de verificación de actualizaciones (segundos)';
COMMENT ON COLUMN "public"."launcher_system_config"."max_download_retries" IS 'Máximo número de reintentos de descarga';
COMMENT ON COLUMN "public"."launcher_system_config"."connection_timeout" IS 'Timeout de conexión (segundos)';
COMMENT ON COLUMN "public"."launcher_system_config"."auto_update_enabled" IS 'Actualización automática habilitada';
COMMENT ON COLUMN "public"."launcher_system_config"."force_ssl" IS 'Forzar conexiones SSL/HTTPS';
COMMENT ON COLUMN "public"."launcher_system_config"."proxy_enabled" IS 'Proxy habilitado/deshabilitado';
COMMENT ON COLUMN "public"."launcher_system_config"."proxy_port" IS 'Puerto del servidor proxy';
COMMENT ON COLUMN "public"."launcher_system_config"."proxy_ip" IS 'Dirección IP del servidor proxy';
COMMENT ON COLUMN "public"."launcher_system_config"."session_duration_hours" IS 'Duración de sesión en horas';
COMMENT ON COLUMN "public"."launcher_system_config"."max_login_attempts" IS 'Máximo intentos de login antes de bloqueo';
COMMENT ON COLUMN "public"."launcher_system_config"."download_rate_limit" IS 'Límite de descargas por hora por IP';
COMMENT ON COLUMN "public"."launcher_system_config"."ip_ban_duration_minutes" IS 'Duración del ban por IP (minutos)';
COMMENT ON COLUMN "public"."launcher_system_config"."rate_limiting_enabled" IS 'Límite de velocidad habilitado';
COMMENT ON COLUMN "public"."launcher_system_config"."log_all_requests" IS 'Registrar todas las solicitudes';
COMMENT ON COLUMN "public"."launcher_system_config"."ip_whitelist" IS 'Lista blanca de IPs (JSON array)';
COMMENT ON COLUMN "public"."launcher_system_config"."webhook_url" IS 'URL para webhooks de notificaciones';
COMMENT ON COLUMN "public"."launcher_system_config"."notification_email" IS 'Email para notificaciones del sistema';
COMMENT ON COLUMN "public"."launcher_system_config"."alert_level" IS 'Nivel de alertas: all, warnings, errors_only';
COMMENT ON COLUMN "public"."launcher_system_config"."notify_new_versions" IS 'Notificar nuevas versiones';
COMMENT ON COLUMN "public"."launcher_system_config"."notify_system_errors" IS 'Notificar errores del sistema';
COMMENT ON COLUMN "public"."launcher_system_config"."notify_high_traffic" IS 'Notificar tráfico alto';
COMMENT ON COLUMN "public"."launcher_system_config"."created_at" IS 'Fecha de creación del registro';
COMMENT ON COLUMN "public"."launcher_system_config"."updated_at" IS 'Fecha de última actualización';
COMMENT ON COLUMN "public"."launcher_system_config"."updated_by" IS 'Usuario que realizó la última actualización';
COMMENT ON TABLE "public"."launcher_system_config" IS 'Configuración general del sistema de launcher';

-- ----------------------------
-- Records of launcher_system_config
-- ----------------------------
INSERT INTO "public"."launcher_system_config" VALUES (1, 'Launcher Admin Panel', 'admin@localhost', 'America/Mexico_City', 'es', 'f', 'Sistema en mantenimiento', 'f', 'http://localhost:5000/', 300, 3, 30, 't', 'f', 'f', 8080, '127.0.0.1', 24, 5, 100, 60, 't', 't', '[]', NULL, NULL, 'all', 't', 't', 'f', '2025-06-04 20:58:28.333425', '2025-06-08 16:28:07.048197', 1);

-- ----------------------------
-- Table structure for launcher_system_status
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_system_status";
CREATE TABLE "public"."launcher_system_status" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_system_status_id_seq'::regclass),
  "is_online" bool,
  "is_maintenance" bool,
  "cpu_usage" float8,
  "memory_usage" float8,
  "disk_usage" float8,
  "active_downloads" int4,
  "total_connections" int4,
  "bandwidth_usage" float8,
  "total_requests_today" int4,
  "failed_requests_today" int4,
  "last_updated" timestamp(6)
)
;

-- ----------------------------
-- Records of launcher_system_status
-- ----------------------------
INSERT INTO "public"."launcher_system_status" VALUES (1, 't', 'f', 0, 0, 0, 0, 0, 0, 234, 0, '2025-06-08 21:28:28.939389');

-- ----------------------------
-- Table structure for launcher_update_package
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_update_package";
CREATE TABLE "public"."launcher_update_package" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_update_package_id_seq'::regclass),
  "filename" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "version_id" int4 NOT NULL,
  "file_path" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "file_size" int8,
  "md5_hash" char(32) COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "uploaded_by" int4
)
;
COMMENT ON TABLE "public"."launcher_update_package" IS 'Paquetes de actualización';

-- ----------------------------
-- Records of launcher_update_package
-- ----------------------------
INSERT INTO "public"."launcher_update_package" VALUES (4, 'update_1.0.0.1.zip', 6, 'uploads\updates\update_1.0.0.1.zip', 962625, '3995b54980eecf66a0ca20c61d7cef9b', '2025-06-03 21:11:53.384842', 1);

-- ----------------------------
-- Table structure for launcher_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_user";
CREATE TABLE "public"."launcher_user" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_user_id_seq'::regclass),
  "username" varchar(80) COLLATE "pg_catalog"."default" NOT NULL,
  "email" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
  "password_hash" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "is_admin" bool DEFAULT false,
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "last_login" timestamp(6)
)
;
COMMENT ON TABLE "public"."launcher_user" IS 'Usuarios del sistema launcher';

-- ----------------------------
-- Records of launcher_user
-- ----------------------------
INSERT INTO "public"."launcher_user" VALUES (1, 'azpirin4', 'granadillo33@gmail.com', 'scrypt:32768:8:1$tODmpVxkXtLLKfc0$fd7b9ccb464e7e75018f679fea8e1529ca709f418e9acc2a6bd1659b251039bf01a27d03851cb3436da53f5f19a71e2335bce6c12d7ce734219841d92aa8b227', 't', '2025-05-28 19:42:09.795977', NULL);
INSERT INTO "public"."launcher_user" VALUES (2, 'admin', 'admin@localhost', 'scrypt:32768:8:1$n5leRKP1eXZ4WWqo$4950eabb7b52a5307be04293d233137016e393fc92e46bd7bc820e5f93f960bcc31fb88867382cb1f7da93218d05c7fc590f7c7737bb648b418ac887aa32e11d', 't', '2025-06-02 04:37:35.911907', NULL);

-- ----------------------------
-- Table structure for launcher_version
-- ----------------------------
DROP TABLE IF EXISTS "public"."launcher_version";
CREATE TABLE "public"."launcher_version" (
  "id" int4 NOT NULL DEFAULT nextval('launcher_version_id_seq'::regclass),
  "version" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "filename" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "file_path" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "is_current" bool DEFAULT false,
  "release_notes" text COLLATE "pg_catalog"."default",
  "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int4
)
;
COMMENT ON TABLE "public"."launcher_version" IS 'Versiones del launcher';

-- ----------------------------
-- Records of launcher_version
-- ----------------------------
INSERT INTO "public"."launcher_version" VALUES (1, '1.0.0.0', 'PBLauncher.exe', 'static/downloads\PBLauncher.exe', 't', '', '2025-05-28 20:23:43.187944', 1);

-- ----------------------------
-- Table structure for login_attempts
-- ----------------------------
DROP TABLE IF EXISTS "public"."login_attempts";
CREATE TABLE "public"."login_attempts" (
  "id" int4 NOT NULL DEFAULT nextval('login_attempts_id_seq'::regclass),
  "username" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "ip_address" varchar(45) COLLATE "pg_catalog"."default" NOT NULL,
  "success" bool,
  "attempt_time" timestamp(6),
  "user_agent" varchar(500) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of login_attempts
-- ----------------------------

-- ----------------------------
-- Indexes structure for table launcher_ban
-- ----------------------------
CREATE INDEX "idx_ban_hwid_hwid" ON "public"."launcher_ban" USING btree (
  "hwid" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_ban_hwid_serial" ON "public"."launcher_ban" USING btree (
  "serial_number" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table launcher_ban
-- ----------------------------
ALTER TABLE "public"."launcher_ban" ADD CONSTRAINT "launcher_ban_hwid_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table launcher_banner_config
-- ----------------------------
ALTER TABLE "public"."launcher_banner_config" ADD CONSTRAINT "launcher_banner_config_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table launcher_banner_slide
-- ----------------------------
ALTER TABLE "public"."launcher_banner_slide" ADD CONSTRAINT "launcher_banner_slide_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_download_log
-- ----------------------------
CREATE INDEX "idx_download_log_created" ON "public"."launcher_download_log" USING btree (
  "created_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_download_log_ip" ON "public"."launcher_download_log" USING btree (
  "ip_address" "pg_catalog"."inet_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table launcher_download_log
-- ----------------------------
ALTER TABLE "public"."launcher_download_log" ADD CONSTRAINT "launcher_download_log_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_game_file
-- ----------------------------
CREATE INDEX "idx_game_file_hash" ON "public"."launcher_game_file" USING btree (
  "md5_hash" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);
CREATE INDEX "idx_game_file_version" ON "public"."launcher_game_file" USING btree (
  "version_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table launcher_game_file
-- ----------------------------
CREATE TRIGGER "update_launcher_game_file_modtime" BEFORE UPDATE ON "public"."launcher_game_file"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_modified_column"();

-- ----------------------------
-- Primary Key structure for table launcher_game_file
-- ----------------------------
ALTER TABLE "public"."launcher_game_file" ADD CONSTRAINT "launcher_game_file_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_game_version
-- ----------------------------
CREATE UNIQUE INDEX "idx_game_version_latest" ON "public"."launcher_game_version" USING btree (
  "is_latest" "pg_catalog"."bool_ops" ASC NULLS LAST
) WHERE is_latest = true;

-- ----------------------------
-- Uniques structure for table launcher_game_version
-- ----------------------------
ALTER TABLE "public"."launcher_game_version" ADD CONSTRAINT "launcher_game_version_version_key" UNIQUE ("version");

-- ----------------------------
-- Checks structure for table launcher_game_version
-- ----------------------------
ALTER TABLE "public"."launcher_game_version" ADD CONSTRAINT "chk_version_format" CHECK (version::text ~ '^[0-9]+(\.[0-9]+){1,3}$'::text);

-- ----------------------------
-- Primary Key structure for table launcher_game_version
-- ----------------------------
ALTER TABLE "public"."launcher_game_version" ADD CONSTRAINT "launcher_game_version_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_news_message
-- ----------------------------
CREATE INDEX "idx_news_active" ON "public"."launcher_news_message" USING btree (
  "is_active" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_news_priority" ON "public"."launcher_news_message" USING btree (
  "priority" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Checks structure for table launcher_news_message
-- ----------------------------
ALTER TABLE "public"."launcher_news_message" ADD CONSTRAINT "chk_priority_range" CHECK (priority >= 0 AND priority <= 100);

-- ----------------------------
-- Primary Key structure for table launcher_news_message
-- ----------------------------
ALTER TABLE "public"."launcher_news_message" ADD CONSTRAINT "launcher_news_message_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table launcher_notification_log
-- ----------------------------
ALTER TABLE "public"."launcher_notification_log" ADD CONSTRAINT "launcher_notification_log_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_server_settings
-- ----------------------------
CREATE INDEX "idx_server_settings_key" ON "public"."launcher_server_settings" USING btree (
  "key" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table launcher_server_settings
-- ----------------------------
CREATE TRIGGER "update_launcher_server_settings_modtime" BEFORE UPDATE ON "public"."launcher_server_settings"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_modified_column"();

-- ----------------------------
-- Uniques structure for table launcher_server_settings
-- ----------------------------
ALTER TABLE "public"."launcher_server_settings" ADD CONSTRAINT "launcher_server_settings_key_key" UNIQUE ("key");

-- ----------------------------
-- Primary Key structure for table launcher_server_settings
-- ----------------------------
ALTER TABLE "public"."launcher_server_settings" ADD CONSTRAINT "launcher_server_settings_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_system_config
-- ----------------------------
CREATE INDEX "idx_launcher_system_config_maintenance_mode" ON "public"."launcher_system_config" USING btree (
  "maintenance_mode" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_launcher_system_config_updated_at" ON "public"."launcher_system_config" USING btree (
  "updated_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table launcher_system_config
-- ----------------------------
CREATE TRIGGER "trigger_update_launcher_system_config_updated_at" BEFORE UPDATE ON "public"."launcher_system_config"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_launcher_system_config_updated_at"();

-- ----------------------------
-- Primary Key structure for table launcher_system_config
-- ----------------------------
ALTER TABLE "public"."launcher_system_config" ADD CONSTRAINT "launcher_system_config_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table launcher_system_status
-- ----------------------------
ALTER TABLE "public"."launcher_system_status" ADD CONSTRAINT "launcher_system_status_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_update_package
-- ----------------------------
CREATE INDEX "idx_update_package_version" ON "public"."launcher_update_package" USING btree (
  "version_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table launcher_update_package
-- ----------------------------
ALTER TABLE "public"."launcher_update_package" ADD CONSTRAINT "launcher_update_package_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table launcher_user
-- ----------------------------
ALTER TABLE "public"."launcher_user" ADD CONSTRAINT "launcher_user_username_key" UNIQUE ("username");
ALTER TABLE "public"."launcher_user" ADD CONSTRAINT "launcher_user_email_key" UNIQUE ("email");

-- ----------------------------
-- Primary Key structure for table launcher_user
-- ----------------------------
ALTER TABLE "public"."launcher_user" ADD CONSTRAINT "launcher_user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table launcher_version
-- ----------------------------
CREATE UNIQUE INDEX "idx_launcher_version_current" ON "public"."launcher_version" USING btree (
  "is_current" "pg_catalog"."bool_ops" ASC NULLS LAST
) WHERE is_current = true;
CREATE INDEX "idx_version_current" ON "public"."launcher_version" USING btree (
  "is_current" "pg_catalog"."bool_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table launcher_version
-- ----------------------------
ALTER TABLE "public"."launcher_version" ADD CONSTRAINT "launcher_version_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table login_attempts
-- ----------------------------
CREATE INDEX "ix_login_attempts_attempt_time" ON "public"."login_attempts" USING btree (
  "attempt_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "ix_login_attempts_ip_address" ON "public"."login_attempts" USING btree (
  "ip_address" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "ix_login_attempts_username" ON "public"."login_attempts" USING btree (
  "username" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table login_attempts
-- ----------------------------
ALTER TABLE "public"."login_attempts" ADD CONSTRAINT "login_attempts_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table launcher_banner_config
-- ----------------------------
ALTER TABLE "public"."launcher_banner_config" ADD CONSTRAINT "launcher_banner_config_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."launcher_user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table launcher_banner_slide
-- ----------------------------
ALTER TABLE "public"."launcher_banner_slide" ADD CONSTRAINT "launcher_banner_slide_banner_id_fkey" FOREIGN KEY ("banner_id") REFERENCES "public"."launcher_banner_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table launcher_game_file
-- ----------------------------
ALTER TABLE "public"."launcher_game_file" ADD CONSTRAINT "launcher_game_file_version_id_fkey" FOREIGN KEY ("version_id") REFERENCES "public"."launcher_game_version" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table launcher_game_version
-- ----------------------------
ALTER TABLE "public"."launcher_game_version" ADD CONSTRAINT "launcher_game_version_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."launcher_user" ("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table launcher_news_message
-- ----------------------------
ALTER TABLE "public"."launcher_news_message" ADD CONSTRAINT "launcher_news_message_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."launcher_user" ("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table launcher_server_settings
-- ----------------------------
ALTER TABLE "public"."launcher_server_settings" ADD CONSTRAINT "launcher_server_settings_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."launcher_user" ("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table launcher_system_config
-- ----------------------------
ALTER TABLE "public"."launcher_system_config" ADD CONSTRAINT "launcher_system_config_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."launcher_user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table launcher_update_package
-- ----------------------------
ALTER TABLE "public"."launcher_update_package" ADD CONSTRAINT "launcher_update_package_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "public"."launcher_user" ("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "public"."launcher_update_package" ADD CONSTRAINT "launcher_update_package_version_id_fkey" FOREIGN KEY ("version_id") REFERENCES "public"."launcher_game_version" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Keys structure for table launcher_version
-- ----------------------------
ALTER TABLE "public"."launcher_version" ADD CONSTRAINT "launcher_version_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."launcher_user" ("id") ON DELETE SET NULL ON UPDATE CASCADE;
