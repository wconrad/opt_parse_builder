Publishing a New Release

# Checklist

* Update `lib/opt_parse_builder/version.rb`
* Update `CHANGELOG.md` with version and date
* Run tests: `rake`
* Commit: `git commit -am "Bump version to X.X.X"`
* Release: `rake release`
* Verify at https://rubygems.org/gems/opt_parse_builder

# Notes

Semantic Versioning: MAJOR.MINOR.PATCH (breaking.feature.bugfix)

What `rake release` does:

* Builds the gem
* Creates git tag vX.X.X
* Pushes tag to GitHub
* Publishes gem to rubygems.org

Dry run: `gem_push=no rake release` (tags but doesn't publish)

# Troubleshooting

No RubyGems credentials: `gem signin`

Release failed mid-way:

```bash
git tag -d vX.X.X              # Delete local tag
git push origin :vX.X.X        # Delete remote tag
rake release                   # Try again
```

Manual publish (if rake release fails):

```bash
gem build opt_parse_builder.gemspec
gem push opt_parse_builder-X.X.X.gem
```
