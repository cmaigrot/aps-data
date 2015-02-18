SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET search_path = public ;
SET default_tablespace = '';
SET default_with_oids = false;

-- *****************************************************************************
BEGIN;
-- *****************************************************************************


-- TYPES ***********************************************************************

DROP TYPE IF EXISTS e_admins_statuses CASCADE;
CREATE TYPE e_admins_statuses AS ENUM ('waiting', 'activated', 'deactivated');

DROP TYPE IF EXISTS e_users_gender CASCADE;
CREATE TYPE e_users_gender AS ENUM ('male', 'female');

DROP TYPE IF EXISTS e_statuses_name CASCADE;
CREATE TYPE e_statuses_name AS ENUM ('active', 'archived', 'treated');

DROP TYPE IF EXISTS e_facebook_albums_type CASCADE;
CREATE TYPE e_facebook_albums_type AS ENUM ('app', 'cover', 'profile' ,'mobile', 'wall', 'normal', 'album');

DROP TYPE IF EXISTS e_facebook_friendlists_list_type CASCADE;
CREATE TYPE e_facebook_friendlists_list_type AS ENUM ( 'close_friends', 'acquaintances', 'restricted', 'user_created', 'education', 'work', 'current_city', 'family');

DROP TYPE IF EXISTS e_facebook_photos_granularity CASCADE;
CREATE TYPE e_facebook_photos_granularity AS ENUM ( 'year', 'month', 'day', 'hour', 'min', 'none' );

DROP TYPE IF EXISTS e_facebook_posts_status_type CASCADE;
CREATE TYPE e_facebook_posts_status_type AS ENUM ( 'mobile_status_update', 'created_note', 'added_photos', 'added_video', 'shared_story', 'created_group', 'created_event', 'wall_post', 'app_created_story', 'published_story', 'tagged_in_photo', 'approved_friend' );

DROP TYPE IF EXISTS e_facebook_posts_type CASCADE;
CREATE TYPE e_facebook_posts_type AS ENUM ( 'link', 'status', 'photo', 'video', 'offer' );

DROP TYPE IF EXISTS e_facebook_posts_privacy_value CASCADE;
CREATE TYPE e_facebook_posts_privacy_value AS ENUM ( 'EVERYONE', 'ALL_FRIENDS', 'FRIENDS_OF_FRIENDS', 'SELF', 'CUSTOM' );

DROP TYPE IF EXISTS e_facebook_posts_privacy_friends CASCADE;
CREATE TYPE e_facebook_posts_privacy_friends AS ENUM ( 'ALL_FRIENDS', 'FRIENDS_OF_FRIENDS', 'SOME_FRIENDS' );

DROP TYPE IF EXISTS e_facebook_users_facebook_events_status CASCADE;
CREATE TYPE e_facebook_users_facebook_events_status AS ENUM ( 'attending', 'declined', 'feed', 'invited', 'maybe', 'moreply' );


-- TABLE admins ****************************************************************
DROP TABLE IF EXISTS admins CASCADE;
CREATE TABLE admins (
    id              SERIAL NOT NULL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    password        VARCHAR(255) NOT NULL,
    status          e_admins_statuses NOT NULL,
    phone_number    VARCHAR(255),
    mobile_number   VARCHAR(255),
    address         VARCHAR(255),
    email           VARCHAR(255),
    permission      INT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX admins_idx ON admins( id );
COMMENT ON TABLE admins IS 'Liste de tous les utilisateurs l\'application';
COMMENT ON COLUMN admins.status IS 'permisions de l\'administrateur';


-- TABLE logs ******************************************************************
DROP TABLE IF EXISTS logs CASCADE;
CREATE TABLE logs (
    id              SERIAL NOT NULL PRIMARY KEY,
    admin_id        INT NOT NULL REFERENCES admins(id),
    content         TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX logs_id_idx ON logs( id );
COMMENT ON TABLE logs IS 'Journalisation de toutes les commandes effectuées par un administrateur';
COMMENT ON TABLE logs IS 'Référence de l\'administrateur ayant effectué la commande';
COMMENT ON COLUMN logs.content IS 'commande SQL exécutée';


-- TABLE users *****************************************************************
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id              SERIAL NOT NULL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    surname         VARCHAR(255) NOT NULL,
    gender          e_users_gender NOT NULL,
    date_of_birth   TIMESTAMP WITH TIME ZONE,
    phone_number    VARCHAR(255),
    mobile_number   VARCHAR(255),
    address         VARCHAR(255),
    email           VARCHAR(255),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX users_idx ON users( id );
COMMENT ON TABLE users IS 'Liste de tous les profils suivi par l\'application';


-- TABLE statuses **************************************************************
DROP TABLE IF EXISTS statuses CASCADE;
CREATE TABLE statuses (
    id              SERIAL NOT NULL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES users(id),
    name            e_statuses_name NOT NULL,
    value           VARCHAR(255),
    message         TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX statuses_idx ON statuses( id );
COMMENT ON TABLE statuses IS 'Liste de tous les status qui ont étés affectés aux utilisateurs';
COMMENT ON COLUMN statuses.user_id IS 'Profil affecté par ce status';
COMMENT ON COLUMN statuses.name IS 'valeur du status (actif, traité, archivé)';
COMMENT ON COLUMN statuses.value IS 'motif du status si traité ou archivé';
COMMENT ON COLUMN statuses.value IS 'motif détaillé du status si traité ou archivé';


-- TABLE facebook_applications *************************************************
DROP TABLE IF EXISTS facebook_applications CASCADE;
CREATE TABLE facebook_applications (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    name            TEXT,
    category        TEXT,
    company         TEXT,
    contact_email   TEXT,
    created_time    TEXT,
    description     TEXT,
    hosting_url     TEXT,
    icon_url        TEXT,
    link            TEXT,
    logo_url        TEXT,

    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_applications_idx ON facebook_applications(id);
COMMENT ON TABLE facebook_applications IS 'cf. Facebook Graph API /application ( https://developers.facebook.com/docs/graph-api/reference/application )';

-- TABLE facebook_accounts *****************************************************
DROP TABLE IF EXISTS facebook_users CASCADE;
DROP TABLE IF EXISTS facebook_photos CASCADE;
CREATE TABLE facebook_photos (
    id      VARCHAR(255) NOT NULL PRIMARY KEY
);
DROP TABLE IF EXISTS facebook_pages CASCADE;
CREATE TABLE facebook_pages (
    id      VARCHAR(255) NOT NULL PRIMARY KEY
);
CREATE TABLE facebook_users (
    id                  VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id             INT NOT NULL REFERENCES users(id),
    about               TEXT,
    bio                 TEXT,
    birthday            VARCHAR(10),
    cover               VARCHAR(255) REFERENCES facebook_photos(id),
    email               TEXT,
    first_name          TEXT,
    gender              TEXT,
    howntown            VARCHAR(255) REFERENCES facebook_pages(id),
    is_verified         BOOLEAN,
    last_name           TEXT,
    link                TEXT,
    locale              TEXT,
    location            VARCHAR(255) REFERENCES facebook_pages(id),
    middle_name         TEXT,
    name                TEXT,
    political           TEXT,
    quotes              TEXT,
    relationship_status TEXT,
    religion            TEXT,
    significant_other   VARCHAR(255) REFERENCES facebook_users(id),
    timezone            INT,
    third_party_id      TEXT,
    verified            BOOLEAN,
    website             TEXT,
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_idx ON facebook_users( id );
COMMENT ON TABLE facebook_users IS 'Liste de tous les comptes facebook. Cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_works ********************************************************
DROP TABLE IF EXISTS facebook_works CASCADE;
CREATE TABLE facebook_works (
    id          SERIAL NOT NULL PRIMARY KEY,
    user_id     VARCHAR (255) REFERENCES facebook_users(id),
    employer    VARCHAR(255) REFERENCES facebook_pages(id),
    location    VARCHAR(255) REFERENCES facebook_pages(id),
    position    VARCHAR(255) REFERENCES facebook_pages(id),
    start_date  TIMESTAMP WITH TIME ZONE,
    end_date    TIMESTAMP WITH TIME ZONE,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_works_idx ON facebook_works( id );
COMMENT ON TABLE facebook_works IS 'cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_projects *****************************************************
DROP TABLE IF EXISTS facebook_projects CASCADE;
CREATE TABLE facebook_projects (
    id          SERIAL NOT NULL PRIMARY KEY,
    description TEXT,
    start_date  TIMESTAMP WITH TIME ZONE,
    end_date    TIMESTAMP WITH TIME ZONE,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_projects_idx ON facebook_projects( id );
COMMENT ON TABLE facebook_projects IS 'cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_projects_facebook_users **************************************
DROP TABLE IF EXISTS facebook_projects_facebook_users CASCADE;
CREATE TABLE facebook_projects_facebook_users (
    project_id          SERIAL REFERENCES facebook_projects(id),
    user_id             VARCHAR(255) REFERENCES facebook_users(id),
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_projects_facebook_users_idx ON facebook_projects_facebook_users( project_id, user_id );
COMMENT ON TABLE facebook_projects_facebook_users IS 'Un profil peut avoir ou avoir eu plusieurs travaux';


-- TABLE facebook_devices ******************************************************
DROP TABLE IF EXISTS facebook_devices CASCADE;
CREATE TABLE facebook_devices (
    id          SERIAL NOT NULL PRIMARY KEY,
    user_id     VARCHAR(255) REFERENCES facebook_users(id),
    hardware    TEXT,
    os          TEXT,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_devices_idx ON facebook_devices( id );
COMMENT ON TABLE facebook_devices IS 'cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_educations ***************************************************
DROP TABLE IF EXISTS facebook_educations CASCADE;
CREATE TABLE facebook_educations (
    id          SERIAL NOT NULL PRIMARY KEY,
    user_id     VARCHAR(255) REFERENCES facebook_users(id),
    school      VARCHAR(255) REFERENCES facebook_pages(id),
    year        VARCHAR(255) REFERENCES facebook_pages(id),
    type        TEXT,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_educations_idx ON facebook_educations( id );
COMMENT ON TABLE facebook_educations IS 'cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_concentrations ***********************************************
DROP TABLE IF EXISTS facebook_concentrations CASCADE;
CREATE TABLE facebook_concentrations (
    id                    SERIAL NOT NULL PRIMARY KEY,
    education_id          SERIAL REFERENCES facebook_educations(id),
    page_id               VARCHAR(255) REFERENCES facebook_pages(id),
    created               TIMESTAMP WITH TIME ZONE,
    modified              TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_concentrations_idx ON facebook_concentrations ( id );
COMMENT ON TABLE facebook_concentrations IS 'cf. Facebook Graph API /user ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user )';


-- TABLE facebook_activities ***************************************************
DROP TABLE IF EXISTS facebook_activities CASCADE;
CREATE TABLE facebook_activities (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_activities_idx ON facebook_activities (user_id, page_id);
COMMENT ON TABLE facebook_activities IS 'cf. Facebook Graph API /user/activities ( https://developers.facebook.com/docs/graph-api/reference/v2.2/user/activities/ )';

-- TABLE facebook_books ********************************************************
DROP TABLE IF EXISTS facebook_books CASCADE;
CREATE TABLE facebook_books (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_books_idx ON facebook_books (user_id, page_id);


-- TABLE facebook_games ********************************************************
DROP TABLE IF EXISTS facebook_games CASCADE;
CREATE TABLE facebook_games (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_games_idx ON facebook_games (user_id, page_id);


-- TABLE facebook_interests ****************************************************
DROP TABLE IF EXISTS facebook_interests CASCADE;
CREATE TABLE facebook_interests (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_interests_idx ON facebook_interests (user_id, page_id);


-- TABLE facebook_movies *******************************************************
DROP TABLE IF EXISTS facebook_movies CASCADE;
CREATE TABLE facebook_movies (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_movies_idx ON facebook_movies (user_id, page_id);


-- TABLE facebook_musics *******************************************************
DROP TABLE IF EXISTS facebook_musics CASCADE;
CREATE TABLE facebook_musics (
    user_id          VARCHAR(255) REFERENCES facebook_users(id),
    page_id          VARCHAR(255) REFERENCES facebook_pages(id),
    created          TIMESTAMP WITH TIME ZONE,
    modified         TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_musics_idx ON facebook_musics (user_id, page_id);


-- TABLE facebook_television ***************************************************
DROP TABLE IF EXISTS facebook_television CASCADE;
CREATE TABLE facebook_television (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_television_idx ON facebook_television (user_id, page_id);


-- TABLE facebook_achievements *************************************************
DROP TABLE IF EXISTS facebook_achievements CASCADE;
CREATE TABLE facebook_achievements (
    id                      VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id                 VARCHAR(255) REFERENCES facebook_users(id),
    publish_time            TIMESTAMP WITH TIME ZONE,
    application_id          VARCHAR(255) REFERENCES facebook_applications(id),
    no_feed_story           BOOLEAN,
    created                 TIMESTAMP WITH TIME ZONE,
    modified                TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_achievements_idx ON facebook_achievements (id);


-- TABLE facebook_albums *******************************************************
DROP TABLE IF EXISTS facebook_albums CASCADE;
CREATE TABLE facebook_albums (
    id                  VARCHAR(255) NOT NULL PRIMARY KEY,
    can_upload          BOOLEAN,
    count               INT,
    cover_photo         VARCHAR(255) REFERENCES facebook_photos(id),
    created_time        TIMESTAMP WITH TIME ZONE,
    description         TEXT,
    user_id             VARCHAR(255) REFERENCES facebook_users(id),
    link                TEXT,
    location            TEXT,
    name                TEXT,
    place               VARCHAR(255) REFERENCES facebook_pages(id),
    privacy             TEXT,
    type                e_facebook_albums_type,
    updated_time        TIMESTAMP WITH TIME ZONE,
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_albums_idx ON facebook_albums (id);


-- TABLE facebook_photos *******************************************************
DROP TABLE IF EXISTS facebook_photos CASCADE;
CREATE TABLE facebook_photos (
    id                          VARCHAR(255) NOT NULL PRIMARY KEY,
    album_id                    VARCHAR(255) REFERENCES facebook_albums(id),
    backdated_time              TIMESTAMP WITH TIME ZONE,
    backdated_time_granularity  e_facebook_photos_granularity,
    created_time                TIMESTAMP WITH TIME ZONE,
    user_id                     VARCHAR(255) REFERENCES facebook_users(id),
    page_id                     VARCHAR(255) REFERENCES facebook_pages(id),
    height                      INT,
    icon                        TEXT,
    link                        TEXT,
    name                        TEXT,
    page_story_id               TEXT,
    picture                     TEXT,
    place                       VARCHAR(255) REFERENCES facebook_pages(id),
    position                    INT,
    source                      TEXT,
    updated_time                TIMESTAMP WITH TIME ZONE,
    width                       INT,
    created                     TIMESTAMP WITH TIME ZONE,
    modified                    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_photos_idx ON facebook_photos(id);


-- TABLE facebook_links ********************************************************
DROP TABLE IF EXISTS facebook_links CASCADE;
CREATE TABLE facebook_links (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    created_time    TIMESTAMP WITH TIME ZONE,
    description     TEXT,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    icon            TEXT,
    link            TEXT,
    message         TEXT,
    name            TEXT,
    picture         TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_links_idx ON facebook_links(id);


-- TABLE facebook_groups *******************************************************
DROP TABLE IF EXISTS facebook_groups CASCADE;
CREATE TABLE facebook_groups (
    id                  VARCHAR(255) NOT NULL PRIMARY KEY,
    cover               VARCHAR(255) REFERENCES facebook_photos(id),
    description         TEXT,
    email               TEXT,
    icon                TEXT,
    link                TEXT,
    name                TEXT,
    owner_user_id       VARCHAR(255) REFERENCES facebook_users(id),
    owner_page_id       VARCHAR(255) REFERENCES facebook_pages(id),
    parent_group_id     VARCHAR(255) REFERENCES facebook_groups(id),
    parent_page_id      VARCHAR(255) REFERENCES facebook_pages(id),
    parent_user_id      VARCHAR(255) REFERENCES facebook_users(id),
    privacy             TEXT,
    updated_time        TIMESTAMP WITH TIME ZONE,
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_groups_idx ON facebook_groups(id);


-- TABLE facebook_pages *********************************************************
DROP TABLE IF EXISTS facebook_pages CASCADE;
CREATE TABLE facebook_pages (
    id                              VARCHAR(255) NOT NULL PRIMARY KEY,
    about                           TEXT,
    birthday                        VARCHAR(10),
    can_post                        BOOLEAN,
    category                        TEXT,
    company_overview                TEXT,
    cover                           VARCHAR(255) REFERENCES facebook_photos(id),
    current_location                TEXT,
    description                     TEXT,
    directed_by                     TEXT,
    founded                         TEXT,
    general_info                    TEXT,
    general_manager                 TEXT,
    global_brand_parent_page        VARCHAR(255) REFERENCES facebook_pages(id),
    hometown                        TEXT,
    is_permanently_closed           BOOLEAN,
    is_published                    BOOLEAN,
    is_unclaimed                    BOOLEAN,
    is_verified                     BOOLEAN,
    likes                           INT,
    link                            TEXT,
    location                        TEXT,
    country                         TEXT,
    city                            TEXT,
    latitude                        TEXT,
    longitude                       TEXT,
    zip                             TEXT,
    state                           TEXT,
    street                          TEXT,
    mission                         TEXT,
    name                            TEXT,
    name_with_location_descriptor   TEXT,
    phone                           TEXT,
    press_contact                   TEXT,
    username                        TEXT,
    website                         TEXT,
    were_here_count                 INT,
    created                         TIMESTAMP WITH TIME ZONE,
    modified                        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_pages_idx ON facebook_pages(id);


-- TABLE facebook_milestones ***************************************************
DROP TABLE IF EXISTS facebook_milestones CASCADE;
CREATE TABLE facebook_milestones (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    title           TEXT,
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    description     TEXT,
    created_time    TIMESTAMP WITH TIME ZONE,
    updated_time    TIMESTAMP WITH TIME ZONE,
    start_time      TIMESTAMP WITH TIME ZONE,
    end_time        TIMESTAMP WITH TIME ZONE,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_milestones_idx ON facebook_milestones(id);


-- TABLE facebook_events *******************************************************
DROP TABLE IF EXISTS facebook_events CASCADE;
CREATE TABLE facebook_events (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    cover           VARCHAR(255) REFERENCES facebook_photos(id),
    description     TEXT,
    end_time        TIMESTAMP WITH TIME ZONE,
    is_date_only    BOOLEAN,
    location        TEXT,
    name            TEXT,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    parent_group    VARCHAR(255) REFERENCES facebook_groups(id),
    privacy         TEXT,
    start_time      TIMESTAMP WITH TIME ZONE,
    ticket_uri      TEXT,
    timezone        TEXT,
    updated_time    TIMESTAMP WITH TIME ZONE,
    venue           VARCHAR(255) REFERENCES facebook_pages(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_events_idx ON facebook_events(id);


-- TABLE facebook_videos *******************************************************
DROP TABLE IF EXISTS facebook_videos CASCADE;
CREATE TABLE facebook_videos (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    created_time    TIMESTAMP WITH TIME ZONE,
    description     TEXT,
    embed_html      TEXT,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    application_id  VARCHAR(255) REFERENCES facebook_applications(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_videos_idx ON facebook_videos(id);


-- TABLE facebook_posts ********************************************************
DROP TABLE IF EXISTS facebook_posts CASCADE;
CREATE TABLE facebook_posts (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    caption         TEXT,
    created_time    TIMESTAMP WITH TIME ZONE,
    description     TEXT,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    application_id  VARCHAR(255) REFERENCES facebook_applications(id),
    icon            TEXT,
    is_hidden       BOOLEAN,
    link            TEXT,
    message         TEXT,
    name            TEXT,
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    picture         TEXT,
    place           VARCHAR(255) REFERENCES facebook_pages(id),
    shares          INT,
    source          TEXT,
    status_type     e_facebook_posts_status_type,
    story           TEXT,
    type            e_facebook_posts_type,
    updated_time    TIMESTAMP WITH TIME ZONE,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_posts_idx ON facebook_posts(id);


-- TABLE facebook_statuses *****************************************************
DROP TABLE IF EXISTS facebook_statuses CASCADE;
CREATE TABLE facebook_statuses (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    application_id  VARCHAR(255) REFERENCES facebook_applications(id),
    message         TEXT,
    place           VARCHAR(255) REFERENCES facebook_pages(id),
    updated_time    TIMESTAMP WITH TIME ZONE,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_statuses_idx ON facebook_statuses(id);


-- TABLE facebook_comments *****************************************************
DROP TABLE IF EXISTS facebook_comments CASCADE;
CREATE TABLE facebook_comments (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    can_comment     BOOLEAN,
    can_remove      BOOLEAN,
    can_hide        BOOLEAN,
    comment_count   INT,
    created_time    TIMESTAMP WITH TIME ZONE,
    like_count      INT,
    message         TEXT,
    parent          VARCHAR(255) REFERENCES facebook_comments(id),
    achivement_id   VARCHAR(255) REFERENCES facebook_achievements(id),
    albums_id       VARCHAR(255) REFERENCES facebook_albums(id),
    comment_id      VARCHAR(255) REFERENCES facebook_comments(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    milestone_id    VARCHAR(255) REFERENCES facebook_milestones(id),
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_comments_idx ON facebook_comments(id);


-- TABLE facebook_friendlists **************************************************
DROP TABLE IF EXISTS facebook_friendlists CASCADE;
CREATE TABLE facebook_friendlists (
    id                  VARCHAR(255) NOT NULL PRIMARY KEY,
    name                TEXT,
    list_type           e_facebook_friendlists_list_type,
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_friendlists_idx ON facebook_friendlists(id);


-- TABLE facebook_categories ***************************************************
DROP TABLE IF EXISTS facebook_categories CASCADE;
CREATE TABLE facebook_categories (
    page_id         VARCHAR(255),
    category        VARCHAR(255) REFERENCES facebook_pages(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_categories_ixd ON facebook_categories(page_id, category);


-- TABLE facebook_images_sources ***********************************************
DROP TABLE IF EXISTS facebook_images_sources CASCADE;
CREATE TABLE facebook_images_sources (
    id          SERIAL NOT NULL PRIMARY KEY,
    photo_id    VARCHAR(255) REFERENCES facebook_photos(id),
    height      INT,
    source      TEXT,
    width       INT,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_images_sources_idx ON facebook_images_sources(id);


-- TABLE facebook_names_tags ***************************************************
DROP TABLE IF EXISTS facebook_names_tags CASCADE;
CREATE TABLE facebook_names_tags (
    id          SERIAL NOT NULL PRIMARY KEY,
    photo_id    VARCHAR(255) REFERENCES facebook_photos(id),
    user_id     VARCHAR(255) REFERENCES facebook_users(id),
    lenght      INT,
    name        TEXT,
    offset_     INT,
    type        TEXT,
    created     TIMESTAMP WITH TIME ZONE,
    modified    TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_names_tags_idx ON facebook_names_tags(id);


-- TABLE facebook_tag **********************************************************
DROP TABLE IF EXISTS facebook_tag CASCADE;
CREATE TABLE facebook_tag (
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    name            TEXT,
    created_time    TIMESTAMP WITH TIME ZONE,
    tagging_user    VARCHAR(255) REFERENCES facebook_users(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_tag_idx ON facebook_tag(photo_id, user_id);


-- TABLE facebook_family *******************************************************
DROP TABLE IF EXISTS facebook_family CASCADE;
CREATE TABLE facebook_family (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    family_user_id  VARCHAR(255) REFERENCES facebook_users(id),
    relationship    TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_family_idx ON facebook_family(user_id, family_user_id);


-- TABLE facebook_friends ******************************************************
DROP TABLE IF EXISTS facebook_friends CASCADE;
CREATE TABLE facebook_friends (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    friend          VARCHAR(255) REFERENCES facebook_users(id),
    still_friend    BOOLEAN DEFAULT true,
    friendlist_id   VARCHAR(255) REFERENCES facebook_friendlists(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_friends_idx ON facebook_friends(user_id, friend, friendlist_id);


-- TABLE facebook_sharedposts **************************************************
DROP TABLE IF EXISTS facebook_sharedposts CASCADE;
CREATE TABLE facebook_sharedposts (
    id              SERIAL NOT NULL PRIMARY KEY,
    sharing_post    VARCHAR(255) REFERENCES facebook_posts(id),
    album_id        VARCHAR(255) REFERENCES facebook_albums(id),
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_sharedposts_idx ON facebook_sharedposts(id);


-- TABLE facebook_pictures *****************************************************
DROP TABLE IF EXISTS facebook_pictures CASCADE;
CREATE TABLE facebook_pictures (
    id              VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id         VARCHAR(255) REFERENCES facebook_pages(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    album_id        VARCHAR(255) REFERENCES facebook_albums(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    url             TEXT,
    is_silhouette   BOOLEAN,
    height          INT,
    width           INT,
    created_time    TIMESTAMP WITH TIME ZONE,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_pictures_idx ON facebook_pictures(id);


-- TABLE facebook_formats ******************************************************
DROP TABLE IF EXISTS facebook_formats CASCADE;
CREATE TABLE facebook_formats (
    id              SERIAL NOT NULL PRIMARY KEY,
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    embed_html      TEXT,
    filter          TEXT,
    height          INT,
    picture         TEXT,
    width           INT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_formats_idx ON facebook_formats(id, video_id);


-- TABLE facebook_locations ****************************************************
DROP TABLE IF EXISTS facebook_locations CASCADE;
CREATE TABLE facebook_locations (
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    location        VARCHAR(255) REFERENCES facebook_pages(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_locations_idx ON facebook_locations(page_id, location);


-- TABLE facebook_photos_facebook_milestones ***********************************
DROP TABLE IF EXISTS facebook_photos_facebook_milestones CASCADE;
CREATE TABLE facebook_photos_facebook_milestones (
    milestone_id    VARCHAR(255) REFERENCES facebook_milestones(id),
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_photos_facebook_milestones_idx ON facebook_photos_facebook_milestones (milestone_id, photo_id);


-- TABLE facebook_likes ********************************************************
DROP TABLE IF EXISTS facebook_likes CASCADE;
CREATE TABLE facebook_likes (
    id              SERIAL NOT NULL PRIMARY KEY,
    user_id         VARCHAR(255) REFERENCES facebook_pages(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    album_id        VARCHAR(255) REFERENCES facebook_albums(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    achivement_id   VARCHAR(255) REFERENCES facebook_achievements(id),
    comment_id      VARCHAR(255) REFERENCES facebook_comments(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    milestone_id    VARCHAR(255) REFERENCES facebook_milestones(id),
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    created_time    TIMESTAMP WITH TIME ZONE,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_likes_idx ON facebook_likes(id);


-- TABLE facebook_posts_privacy ******************************************************
DROP TABLE IF EXISTS facebook_posts_privacy CASCADE;
CREATE TABLE facebook_posts_privacy (
    id              SERIAL NOT NULL PRIMARY KEY,
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    description     TEXT,
    value           e_facebook_posts_privacy_value,
    friends         e_facebook_posts_privacy_friends,
    allow           TEXT,
    deny            TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_posts_privacy_idx ON facebook_posts_privacy(id);


-- TABLE facebook_posts_properties ***************************************************
DROP TABLE IF EXISTS facebook_posts_properties CASCADE;
CREATE TABLE facebook_posts_properties (
    id              SERIAL NOT NULL PRIMARY KEY,
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    name            TEXT,
    text_           TEXT,
    href            TEXT,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_posts_properties_idx ON facebook_posts_properties(id);


-- TABLE facebook_posts_to *****************************************************
DROP TABLE IF EXISTS facebook_posts_to CASCADE;
CREATE TABLE facebook_posts_to (
    id              SERIAL NOT NULL PRIMARY KEY,
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    groups_id       VARCHAR(255) REFERENCES facebook_groups(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    application_id  VARCHAR(255) REFERENCES facebook_applications(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_posts_to_idx ON facebook_posts_to(id);


-- TABLE facebook_posts_with_tags *****************************************************
DROP TABLE IF EXISTS facebook_posts_with_tags CASCADE;
CREATE TABLE facebook_posts_with_tags (
    id              SERIAL NOT NULL PRIMARY KEY,
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    groups_id       VARCHAR(255) REFERENCES facebook_groups(id),
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    application_id  VARCHAR(255) REFERENCES facebook_applications(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_posts_with_tags_idx ON facebook_posts_with_tags(id);


-- TABLE facebook_messages_tags ************************************************
DROP TABLE IF EXISTS facebook_messages_tags CASCADE;
CREATE TABLE facebook_messages_tags (
    id                  SERIAL NOT NULL PRIMARY KEY,
    tagging_post_id     VARCHAR(255) REFERENCES facebook_posts(id),
    user_id             VARCHAR(255) REFERENCES facebook_pages(id),
    event_id            VARCHAR(255) REFERENCES facebook_events(id),
    album_id            VARCHAR(255) REFERENCES facebook_albums(id),
    page_id             VARCHAR(255) REFERENCES facebook_pages(id),
    post_id             VARCHAR(255) REFERENCES facebook_posts(id),
    status_id           VARCHAR(255) REFERENCES facebook_statuses(id),
    achivement_id       VARCHAR(255) REFERENCES facebook_achievements(id),
    comment_id          VARCHAR(255) REFERENCES facebook_comments(id),
    link_id             VARCHAR(255) REFERENCES facebook_links(id),
    milestone_id        VARCHAR(255) REFERENCES facebook_milestones(id),
    photo_id            VARCHAR(255) REFERENCES facebook_photos(id),
    video_id            VARCHAR(255) REFERENCES facebook_videos(id),
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_messages_tags_idx ON facebook_messages_tags(id);


-- TABLE facebook_users_facebook_groups ****************************************
DROP TABLE IF EXISTS facebook_users_facebook_groups CASCADE;
CREATE TABLE facebook_users_facebook_groups (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    administrator   BOOLEAN,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_facebook_groups_idx ON facebook_users_facebook_groups(user_id, group_id);


-- TABLE facebook_users_facebook_albums ****************************************
DROP TABLE IF EXISTS facebook_users_facebook_albums CASCADE;
CREATE TABLE facebook_users_facebook_albums (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    album_id        VARCHAR(255) REFERENCES facebook_albums(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_facebook_albums_idx ON facebook_users_facebook_albums(user_id, album_id);


-- TABLE facebook_users_facebook_photos ****************************************
DROP TABLE IF EXISTS facebook_users_facebook_photos CASCADE;
CREATE TABLE facebook_users_facebook_photos (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    photo_id        VARCHAR(255) REFERENCES facebook_photos(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_facebook_photos_idx ON facebook_users_facebook_photos(user_id, photo_id);


-- TABLE facebook_users_facebook_videos ****************************************
DROP TABLE IF EXISTS facebook_users_facebook_videos CASCADE;
CREATE TABLE facebook_users_facebook_videos (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    video_id        VARCHAR(255) REFERENCES facebook_videos(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_facebook_videos_idx ON facebook_users_facebook_videos(user_id, video_id);


-- TABLE facebook_users_facebook_events ****************************************
DROP TABLE IF EXISTS facebook_users_facebook_events CASCADE;
CREATE TABLE facebook_users_facebook_events (
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    event_id        VARCHAR(255) REFERENCES facebook_videos(id),
    status          e_facebook_users_facebook_events_status,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_users_facebook_events_idx ON facebook_users_facebook_events(user_id, event_id);


-- TABLE facebook_user_feeds ***************************************************
DROP TABLE IF EXISTS facebook_user_feeds CASCADE;
CREATE TABLE facebook_user_feeds (
    id              SERIAL NOT NULL PRIMARY KEY,
    user_id         VARCHAR(255) REFERENCES facebook_users(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_user_feeds_idx ON facebook_user_feeds(id);


-- TABLE facebook_event_feeds **************************************************
DROP TABLE IF EXISTS facebook_event_feeds CASCADE;
CREATE TABLE facebook_event_feeds (
    id              SERIAL NOT NULL PRIMARY KEY,
    event_id        VARCHAR(255) REFERENCES facebook_events(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_event_feeds_idx ON facebook_event_feeds(id);


-- TABLE facebook_group_feeds **************************************************
DROP TABLE IF EXISTS facebook_group_feeds CASCADE;
CREATE TABLE facebook_group_feeds (
    id              SERIAL NOT NULL PRIMARY KEY,
    group_id        VARCHAR(255) REFERENCES facebook_groups(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_group_feeds_idx ON facebook_group_feeds(id);


-- TABLE facebook_page_feeds ***************************************************
DROP TABLE IF EXISTS facebook_page_feeds CASCADE;
CREATE TABLE facebook_page_feeds (
    id              SERIAL NOT NULL PRIMARY KEY,
    page_id         VARCHAR(255) REFERENCES facebook_pages(id),
    link_id         VARCHAR(255) REFERENCES facebook_links(id),
    post_id         VARCHAR(255) REFERENCES facebook_posts(id),
    status_id       VARCHAR(255) REFERENCES facebook_statuses(id),
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX facebook_page_feeds_idx ON facebook_page_feeds(id);


-- TABLE twitter_users *********************************************************
DROP TABLE IF EXISTS twitter_users CASCADE;
CREATE TABLe twitter_users (
    id                      BIGINT NOT NULL PRIMARY KEY,
    user_id                 INT REFERENCES users(id),
    name                    TEXT,
    profile_image_url       TEXT,
    created_at              TIMESTAMP WITH TIME ZONE,
    location                TEXT,
    favourites_count        INT,
    listed_count            INT,
    followers_count         INT,
    verified                BOOLEAN,
    geo_enabled             BOOLEAN,
    time_zone               TEXT,
    description             TEXT,
    statuses_count          INT,
    friends_count           INT,
    following               INT,
    screen_name             TEXT,
    created                 TIMESTAMP WITH TIME ZONE,
    modified                TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX twitter_users_idx ON twitter_users(id);


-- TABLE twitter_friendships ***************************************************
DROP TABLE IF EXISTS twitter_friendships CASCADE;
CREATE TABLE twitter_friendships (
    user_id         BIGINT REFERENCES twitter_users(id),
    friend          BIGINT REFERENCES twitter_users(id),
    still_friend    BOOLEAN DEFAULT true,
    created         TIMESTAMP WITH TIME ZONE,
    modified        TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX twitter_friendships_idx ON twitter_friendships(user_id, friend);

COMMENT ON TABLE twitter_friendships IS 'Liste des personnes que sui l\'utilisateur';
COMMENT ON COLUMN twitter_friendships.user_id IS 'Correspond à un follower';
COMMENT ON COLUMN twitter_friendships.friend IS 'Profil suivi par le follower';


-- TABLE twitter_statuses ******************************************************
DROP TABLE IF EXISTS twitter_statuses CASCADE;
CREATE TABLE twitter_statuses (
    id                          BIGINT NOT NULL PRIMARY KEY,
    user_id                     INT REFERENCES twitter_users(id),
    created_at                  TIMESTAMP WITH TIME ZONE,
    in_reply_to_user_id         INT,
    retweet_count               INT,
    in_reply_to_status_id       INT,
    text_                       VARCHAR(140),
    in_reply_to_screen_name     TEXT,
    place                       TEXT,
    source                      TEXT,
    full_content                TEXT,
    created                     TIMESTAMP WITH TIME ZONE,
    modified                    TIMESTAMP WITH TIME ZONE

);
CREATE UNIQUE INDEX twitter_statuses_idx ON twitter_statuses(id);


-- TABLE rates *************************************************************
DROP TABLE IF EXISTS rates CASCADE;
CREATE TABLE rates (
    id                  SERIAL NOT NULL PRIMARY KEY,
    twitter_status_id   BIGINT REFERENCES twitter_statuses(id),
    facebook_post_id    VARCHAR REFERENCES facebook_posts(id),
    facebook_status_id  VARCHAR REFERENCES facebook_statuses(id),
    facebook_link_id    VARCHAR REFERENCES facebook_links(id),
    facebook_comment_id VARCHAR REFERENCES facebook_comments(id),
    rate                INT,
    anorexia            INT,
    depression          INT,
    harassment          INT,
    uncategorized       INT,
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);


-- TABLE teams *****************************************************************
DROP TABLE IF EXISTS teams CASCADE;
CREATE TABLE teams (
    id                  SERIAL NOT NULL PRIMARY KEY,
    admin_id            INT REFERENCES admins(id),
    user_id             INT REFERENCES users(id),
    created             TIMESTAMP WITH TIME ZONE,
    modified            TIMESTAMP WITH TIME ZONE
);
CREATE UNIQUE INDEX teams_idx ON teams(id);


-- *****************************************************************************
COMMIT;
-- *****************************************************************************

-- TODO :
-- * Rajouter une table pour suivre l'évolution d'un profil sur facebook
-- * Rajouter une table pour suivre l'évolution d'un profil sur twitter
-- * Rajouter une table pour les notes des médecins
-- * Voir comment stocker les métas infos (e.g : Un medecin met en favoris un message)
