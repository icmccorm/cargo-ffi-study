DROP VIEW IF EXISTS candidates;
DROP VIEW IF EXISTS active_crates;
DROP VIEW IF EXISTS latest_created_version;
DROP VIEW IF EXISTS latest_updated_version;

CREATE VIEW latest_created_version AS (
SELECT v_last_updated.crate_id, v_last_updated.created_at, vids.id as version_id, vids.num FROM (SELECT DISTINCT ON (versions.crate_id) versions.crate_id, max(created_at) as created_at
      FROM versions
      GROUP BY crate_id) AS v_last_updated
         INNER JOIN
         (SELECT crate_id, id, created_at, num FROM versions) AS vids
         ON v_last_updated.crate_id = vids.crate_id AND
            v_last_updated.created_at = vids.created_at
    );

CREATE VIEW latest_updated_version AS (
SELECT v_last_updated.crate_id, v_last_updated.updated_at, vids.id as version_id, vids.num FROM (SELECT DISTINCT ON (versions.crate_id) versions.crate_id, max(updated_at) as updated_at
      FROM versions
      GROUP BY crate_id) AS v_last_updated
         INNER JOIN
         (SELECT crate_id, id, updated_at, num FROM versions) AS vids
         ON v_last_updated.crate_id = vids.crate_id AND
            v_last_updated.updated_at = vids.updated_at
    );

CREATE VIEW active_crates AS
(
SELECT DISTINCT ON (crates.name) crates.name, lv.crate_id, lv.version_id as version_id, SUM(downloads.downloads) as num_downloads
FROM latest_created_version lv
         INNER JOIN crates ON lv.crate_id = crates.id
         INNER JOIN (SELECT * FROM version_downloads) as downloads
                    ON lv.version_id = downloads.version_id
WHERE lv.created_at > current_timestamp - interval '1 year'
  AND downloads.date > current_timestamp - interval '1 year'
GROUP BY crates.name, lv.crate_id, lv.version_id, crates.updated_at
);

select crates_categories.crate_id, active_crates.name, updated_at, crates.created_at, downloads, repository, num as version from active_crates inner join crates_categories on active_crates.crate_id = crates_categories.crate_id
    INNER JOIN categories c on crates_categories.category_id = c.id
    INNER JOIN crates on crates.id = active_crates.crate_id
     inner join
    (select crate_id, num from latest_created_version) as lv ON active_crates.crate_id = lv.crate_id
WHERE category = 'External FFI bindings'