# Checklinks

Checklinks finds broken or redirected links in a static webpage.

```
% gem install checklinks
% checklinks **/*.md
```

It uses code from [awesome_bot](https://github.com/dkhamsing/awesome_bot), but the output is much more terse so it's easier to find which links are broken, and it also prints link locations which makes updating them easier.

## Configuration

```
% checklinks --config .checklinks.yaml **/*.md
```

```yaml
ignore:
  exact:
  - ...
  prefixes:
  - ...
  suffixes:
  - ...
  forbidden:
    exact:
    - ...
    prefixes:
    - ...
    suffixes:
    - ...
  redirect:
    exact:
    - ...
    prefixes:
    - ...
    suffixes:
    - ...
```

## Author

[Chris Seaton](https://chrisseaton.com/)

## License

Copyright © 2020 Chris Seaton. Available under the MIT license.
