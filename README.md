# linux-egradjani

Steps on how-to setup e-Građani app for identification (Chrome/Firefox) and signing documents (LibreOffice) on Linux (Ubuntu 21.04.)

## Linux requirements

1. Install smart-card reader tooling
    ```bash
    # if on Ubunt 22.04 LTS keep only `pcsc-tools` `opensc` packages and try without others
    sudo apt-get install -y libccid ccid pcsc-tools opensc
    ```

2. Start the service
    ```bash
    sudo systemctl start pcscd.service
    sudo systemctl enable pcscd.service
    ```

## e-Građani requirements

To use your ID certificates, you must activate your eOI, and check [eid.hr](https://eid.hr/hr/eosobna/clanci/aktiviraj-eoi) for steps.

There you should find the latest linux `.deb` package. For the previous versions check [here](https://eid.hr/hr/eosobna/clanci/ranije-verzije-middlewara).

## Step-by-step

1. Download `eidmiddleware` app that contains all services, certificates, etc.
    ```bash
    sudo dpkg -i eidmiddleware_vX.Y.Z_amd64.deb 
    ```

2. Create a new local NSS db
    ```bash
    rm -rf $HOME/.pki/nssdb
    mkdir -p $HOME/.pki/nssdb
    # if on Ubunt 22.04 LTS skip this command
    sudo chmod 777 /etc/pam_pkcs11/nssdb
    certutil -d $HOME/.pki/nssdb -N --empty-password
    sudo chmod 777 $HOME/.pki/nssdb/pkcs11.txt
    ```

2. Add  the named module `HR eID` to NSS module database with `PKCS #11` implementation libfile
    ```bash
    modutil \
      -dbdir sql:$HOME/.pki/nssdb \
      -add "HR eID" -libfile /usr/lib/akd/eidmiddleware/pkcs11/libEidPkcs11.so \
      -mechanisms FRIENDLY \
      -force 
    ```
   Flag `-mechanisms FRIENDLY` is required to work on Chromium/Chrome,
   check [here](https://bugs.chromium.org/p/chromium/issues/detail?id=42073#c76) for details.

3. Check whether `HR eID` is added to NSS db
    ```bash
    modutil -dbdir sql:$HOME/.pki/nssdb/ -list
    ```

4. Turn on Client and Signer apps.

## Identification

1. Go to [gov.hr](https://gov.hr) and login with eOsobna option
    - Chrome:

         <img src="img/chrome-popup1.png" alt="drawing" width="500"/>

         <img src="img/chrome-popup2.png" alt="drawing" width="500"/>

    - Firefox:

         <img src="img/firefox-popup.png" alt="drawing" width="500"/>

## Signing documents

To sign documents using `LibreOffice` go to

```
LibreOffice > Tools > Options > Security > Certificate... >  Select NSS path
```

and navigate to folder `$HOME/.pki/nssdb` and press OK and restart LibreOffice. Go to

```
File > Digital Signatures > Digital Signatures... > Sign Document...
```

and pop-ups for Signature/Identification will appear.

<p align="center"><img src="img/libreoffice-signature.png" alt="drawing" width="500"/></p>

## References

For Debugging check [DEBUG.md](DEBUG.md)

- https://www.eid.hr/hr
- https://hr.comp.os.linux.narkive.com/7ObBGSco/eoi-na-ubuntu (Thanks!)
- https://bugs.chromium.org/p/chromium/issues/detail?id=42073
- https://www.suse.com/c/configuring-smart-card-authentication-suse-linux-enterprise/
