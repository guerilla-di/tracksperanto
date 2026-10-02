# Ractor compatibility: changes to dependency gems

Goal: make Tracksperanto usable inside Ractors. This turned up problems in four of its own
dependency gems. They were fixed, version-bumped, tested and pushed directly to `master` on GitHub.
Nothing has been published to RubyGems yet.

Ractors are only targeted on **Ruby 4.0+**. On Ruby 3.x, stdlib `Tempfile.new` can't be used from
a non-main Ractor, and both Obuf and the Tracksperanto pipeline rely on it. All Ractor tests
`omit` themselves on Rubies that lack `Ractor#value`.

## Summary

| Gem | Version | Repository | Commits |
|---|---|---|---|
| obuf | 1.2.1 → **1.3.0** | [julik/obuf](https://github.com/julik/obuf) | [cd93c3b](https://github.com/julik/obuf/commit/cd93c3b7cd8f92a7e93b1c47055cbb72bea08b33), [19652e3](https://github.com/julik/obuf/commit/19652e301f4d592a445b76b7e3ee9ad033d0e9fb) — [full diff](https://github.com/julik/obuf/compare/17ae5304022e3e3438ed2697ee492050f61c8cf6...19652e301f4d592a445b76b7e3ee9ad033d0e9fb) |
| tickly | 2.1.7 → **2.2.0** | [julik/tickly](https://github.com/julik/tickly) | [900e275](https://github.com/julik/tickly/commit/900e27579efdb3280b61c5b2bbd8c7a8cdd16420), [f4f6cc0](https://github.com/julik/tickly/commit/f4f6cc0c15adcf23c759001e8cc75d020ca6206d) — [full diff](https://github.com/julik/tickly/compare/0b52d2bc46cd8fd63ba93e0884ae31a24598df9a...f4f6cc0c15adcf23c759001e8cc75d020ca6206d) |
| flame_channel_parser | 4.1.1 → **4.2.0** | [guerilla-di/flame_channel_parser](https://github.com/guerilla-di/flame_channel_parser) | [b5cde7f](https://github.com/guerilla-di/flame_channel_parser/commit/b5cde7f62e379c09d31f99bb7620427401be7405), [826beff](https://github.com/guerilla-di/flame_channel_parser/commit/826beffa1019a615917ce3f4e8fbf50ef3401d1e) — [full diff](https://github.com/guerilla-di/flame_channel_parser/compare/1a35317c07c66597633229187e26460b75afa0c2...826beffa1019a615917ce3f4e8fbf50ef3401d1e) |
| framecurve | 2.2.3 → **2.2.4** | [guerilla-di/framecurve](https://github.com/guerilla-di/framecurve) | [63780fe](https://github.com/guerilla-di/framecurve/commit/63780fe0f0b6361d4f732dd248ecf49ec055c3aa), [cac3aaa](https://github.com/guerilla-di/framecurve/commit/cac3aaa2d6f8a69bab09441770c44c344bfcd8a1) — [full diff](https://github.com/guerilla-di/framecurve/compare/74750a49d20ed9e356242f329398fc6f62678335...cac3aaa2d6f8a69bab09441770c44c344bfcd8a1) |

Test results after the changes, run with `bundle exec rake test`:

| Gem | Ruby 4.0.0 | Ruby 3.4.1 | Before (master, modern Ruby) |
|---|---|---|---|
| obuf | 16 tests, 0 failures | 16 tests, 0 failures, 1 omission (Ractor) | suite did not run (Jeweler, flexmock 0.8) |
| tickly | 35 tests, 0 failures | 35 tests, 0 failures, 1 omission (Ractor) | suite did not run (rake 10) |
| flame_channel_parser | 87 tests, 0 failures | 87 tests, 0 failures, 1 omission (Ractor) | 2 failures, 6 errors (when run without rake) |
| framecurve | 51 tests, 0 failures | 51 tests, 0 failures | 3 failures, 24 errors (when run without rake) |

Each new Ractor test was checked to **fail** with the library fix reverted, so it guards against regressions.

## obuf 1.3.0

What was done:

- **Ractor:** added `# shareable_constant_value: literal` to `lib/obuf/lens.rb`. `Obuf::Lens::DELIM` and
  `END_RECORD` were unfrozen strings, which can't be read from a non-main Ractor.
- **Ractor test:** `test_works_inside_a_ractor` round-trips objects through an Obuf (including `#[]`)
  inside a Ractor.
- **Build:** removed **Jeweler**. The gemspec is now hand-written (version taken from `Obuf::VERSION`, files
  from `lib/` plus README and History). The Rakefile uses `bundler/gem_tasks`, and the Gemfile is just `gemspec`.
- **Dev dependencies:** dropped the `flexmock ~> 0.8` pin (works with current flexmock) and the Jeweler
  dependency.
- **Removed** `.travis.yml` and `.autotest`.
- **Gemspec:** declared `required_ruby_version >= 2.6`.
- **History.txt** entry for 1.3.0.

What was not done:

- **No `Tempfile.create` fallback** that would make Obuf work in Ractors on Ruby 3.x. It's possible, but
  you would lose the GC-driven cleanup of `Tempfile.new`. I decided against it because Ruby 4.0 fixes this
  in the standard library.
- **The old FlexMock 0.8 monkeypatch** in `test/test_obuf.rb` was left in place. It's harmless.
- **No CI** (GitHub Actions) was added.

## tickly 2.2.0

What was done:

- **Ractor:** added `# shareable_constant_value: literal` to `lib/tickly/parser.rb` and `lib/tickly/curve.rb`.
  `Tickly::Parser::TERMINATORS`, `QUOTES` and `ESC` were mutable and blew up in the parser loop.
  `ESC = 92.chr` is computed, so it is now explicitly `.freeze`d.
- **Ractor test:** `test/test_ractor.rb` parses a Nuke 7 script with `Tickly::NodeProcessor` inside a Ractor.
- **Dev dependencies:** unpinned `rake ~> 10` (it crashes on Ruby 3.4 with `undefined method '=~' for Proc`)
  and `rdoc ~> 3`. Replaced the unused `ruby-prof` with `benchmark`, which is a bundled gem on 4.0 and
  needed by the benchmark test. In the Rakefile, `Rake::RDocTask` became `RDoc::Task`.
- **Gemspec:** removed the stale `rubygems_version` and `specification_version` stamps, and declared
  `required_ruby_version >= 2.6`.

What was not done:

- **Tickly has no changelog file**, so the change is only described in the commit messages.
- **`.travis.yml` was left in place**, and no GitHub Actions were added.

## flame_channel_parser 4.2.0

What was done:

- **Ractor constants:** added `# shareable_constant_value: literal` to every file in `lib/` that defines
  constants. Computed constants are now frozen explicitly:
  - `HERMATRIX` (a Matrix)
  - the template paths in the framecurve writers
  - `TOKEN`
  - `TIME`
- **`$stdout` default:** `Extractor::DEFAULTS` held `$stdout`, which is never shareable. The default is now
  merged in at call time.
- **Class variables:** these can't be read from non-main Ractors.
  - `Builder` used `@@camelizations` as a memo cache. It is now a per-instance cache.
  - `FramecurveWriters::Base` kept its registry in `@@writers`. It is now a frozen array in a class-level ivar.
- **Ruby 3 bug:** removed `&Proc.new` without a block, which raises since Ruby 3.0, from:
  - `FlameChannelParser.parse`
  - `XMLParser#parse`
  - `FramecurveWriters::Base.with_each_writer`

  This bug made `FlameChannelParser.parse` with a block unusable on any modern Ruby.
- **Dependencies:**
  - declared `matrix` and `rexml` as runtime dependencies, since neither is a default gem on 3.4+
    (both are `require`d by the library)
  - now require `framecurve ~> 2, >= 2.2.4` for its matching `Proc.new` fix
  - unpinned `rake`
- **Ractor test:** `test/test_ractor.rb` parses a Flame action, samples every channel with
  `Interpolator`, and writes a block with `Builder`, both inside a Ractor and on the main Ractor. The results
  must be identical.
- **Executables:** the gemspec now picks up every binary in `bin/`. `flame_channel_inspect` was added in 4.1.0
  but never listed in `s.executables`, so it was never installed.
- **Gemspec:** removed the stale `rubygems_version` and `specification_version` stamps, and declared
  `required_ruby_version >= 2.6`.
- **Gemfile:** sourced `framecurve` from GitHub until 2.2.4 was released. It went back to plain `gemspec` in
  [7028de7](https://github.com/guerilla-di/flame_channel_parser/commit/7028de70a403aa645d2a878fe1d598d200fbf2d9).
- **History.txt** entry for 4.2.0.

What was not done:

- **Not checked for Ractor use:**
  - `update_hints`, a runtime dependency that does a network version check, was not touched or reviewed
    for Ractors.
  - `XMLParser` (Flame 2012+ XML setups) goes through REXML, which is only Ractor-safe on REXML master
    (see below). Tracksperanto's own Flame import goes through the plain-text parser path.
  - The timewarp/CLI code paths only got the `Proc.new` fixes. Parsing, interpolation and Builder are the
    paths verified inside Ractors.
- **`.travis.yml` and `.autotest` were left in place.**

## framecurve 2.2.4

This gem wasn't part of the original scope. flame_channel_parser's tests exercise it, and it had the same
Ruby 3 breakage.

What was done:

- **Ruby 3 bug:** `Framecurve::Curve#each` and `XMLBridge#xpath_each` used `&Proc.new` without a block,
  which raises on Ruby 3.0+. `Curve#each` is used by practically everything in the gem, so this broke most
  of it on modern Ruby.
- **Dependencies:** declared `rexml` as a runtime dependency and unpinned `rake ~> 10`.
- **Gemspec:** removed the stale `# stub:` header and the `rubygems_version` and `specification_version`
  stamps, and declared `required_ruby_version >= 2.6`.
- **History.txt** entry for 2.2.4.

What was not done:

- **No Ractor-specific changes or tests.** The only constants are regex literals, which are already shareable.
- **The gem still packages its test fixtures** (about 3 MB). It is the same size as 2.2.3, so this is
  unchanged behaviour.

## Not changed, but relevant

- **REXML** (`ruby/rexml`, not ours) uses class variables and mutable constants that break in Ractors.
  Upstream fixed this in [ruby/rexml#344](https://github.com/ruby/rexml/pull/344) (merged 2026-09-06), but
  the latest release is still 3.4.4. Tracksperanto's Gemfile uses rexml from git `master` until a release
  ships. Tracksperanto's MatchMover RZML importer needs this.
- **progressive_io** needed no changes. The already-released 2.0.2 is Ractor-safe (`SimpleDelegator`),
  whereas 1.x (`DelegateClass(IO)`) is not. Tracksperanto moved from `~> 1` to `~> 2`.
- **bychar** and **update_hints** were cloned and inspected but not changed.
- **GitHub reported a Dependabot alert** when pushing tickly and framecurve. Neither alert showed as open
  through the API afterwards. The likely cause is the old `rake ~> 10` pin, which is now gone, but that
  is unconfirmed.

## Tracksperanto itself (uncommitted at the time of writing)

- **Ractor fixes:**
  - frozen-array registries for importers, exporters, tools and tool parameters
  - string-`class_eval` accessors instead of `define_method` in Casts, Safety, Mux and Crop
  - shareable constants
  - progressive_io 2 API
- **Smoke test:** `test/test_ractor_smoke.rb` converts 16 fixtures covering all 13 importers. Each runs in
  its own Ractor through the full pipeline with three tools and all exporters, and is compared against a
  main-Ractor run.
- **Gemspec:** requires obuf ≥ 1.3.0, tickly ≥ 2.2.0, flame_channel_parser ≥ 4.2.0 and progressive_io ~> 2.
  The Gemfile sources the four gems and rexml from GitHub until they are released.

## Built gems

Built with `bundle exec rake build` (bundler gem tasks) on Ruby 4.0.0. They build without warnings.

- `~/Code/libs/framecurve/pkg/framecurve-2.2.4.gem`
- `~/Code/libs/flame_channel_parser/pkg/flame_channel_parser-4.2.0.gem`
- `~/Code/libs/obuf/pkg/obuf-1.3.0.gem`
- `~/Code/libs/tickly/pkg/tickly-2.2.0.gem`

Release order: framecurve first, since flame_channel_parser depends on 2.2.4. The other three can follow in
any order. After that:

1. Drop the `git:` lines from the flame_channel_parser and Tracksperanto Gemfiles.
2. Drop rexml's `git:` line once a release after 3.4.4 is out.

## Status after release (2026-10-02)

obuf 1.3.0, tickly 2.2.0, flame_channel_parser 4.2.0 and framecurve 2.2.4 are on Rubygems. Tracksperanto's
Gemfile now uses them from Rubygems; only `rexml` is still sourced from git (no release after 3.4.4 yet).

- Tracksperanto suite: Ruby 4.0.0 - 321 tests, 0 failures; Ruby 3.4.1 - 321 tests, 0 failures, 1 omission
- Against _released_ rexml 3.4.4 the Ractor smoke test fails only on the MatchMover RZML fixture
  (`@@entity_expansion_limit from REXML::Security`); every other format converts inside Ractors

Spotted but not addressed: `Tickly::Parser` and Tracksperanto's Shake lexer append to unfrozen string
literals ("literal string will be frozen in the future" under `-W:deprecated`). Harmless today, will break
once Ruby freezes string literals by default.
