# Future: dpkg triggers for man page changes

## Idea

Use **dpkg triggers** on systems that use dpkg/apt so that an action runs whenever something under the man page tree changes (e.g. `/usr/share/man`). This is not “when this specific man page is installed”, but “when anything in the man hierarchy has changed”.

## Why

If natl later adds a **man-page index** (e.g. for RAG/embeddings), that index would need to be rebuilt when new man pages are installed or removed. A dpkg trigger would run our update script automatically on such events, without cron or inotify.

## How (outline)

1. **Trigger declaration**  
   A package (or a dedicated “natl-trigger” package) declares an interest in a path, e.g.:
   - Path: `interest-noawait /usr/share/man`

2. **Trigger activation**  
   When any package installs/removes files under that path, dpkg runs the trigger. Our package would have a **triggered script** (e.g. in `/etc/apt/apt.conf.d/` or a maintainer script) that invokes something like:
   - `natl-index-man-pages --update`  
   (or whatever the future indexing command is.)

3. **Implementation**  
   - Add a small debian/natl package that:
     - Declares the trigger
     - Runs the index-update (or a no-op stub until the feature exists)
   - Or document how to register the trigger for a manually installed natl (e.g. via a postinst that registers the trigger and a prerm/postrm that unregisters it).

## References

- `dpkg-trigger(1)`, `Debian Policy § 4.12 (Triggers)`
- Trigger syntax: `interest-noawait <path>` / `activate-noawait <path>`

## Status

Idea only; no implementation yet. No dependency on this for current natl behavior.
