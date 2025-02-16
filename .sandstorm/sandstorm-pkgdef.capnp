@0xee9207e3a666d632;

using Spk = import "/sandstorm/package.capnp";
# This imports:
#   $SANDSTORM_HOME/latest/usr/include/sandstorm/package.capnp
# Check out that file to see the full, documented package definition format.

const pkgdef :Spk.PackageDefinition = (
  # The package definition. Note that the spk tool looks specifically for the
  # "pkgdef" constant.

  id = "h37dm17aa89yrd8zuqpdn36p6zntumtv08fjpu8a8zrte7q1cn60",
  # Your app ID is actually its public key. The private key was placed in
  # your keyring. All updates must be signed with the same key.

  manifest = (
    # This manifest is included in your app package to tell Sandstorm
    # about your app.

    appTitle = (defaultText = "Etherpad"),

    appVersion = 29,  # Increment this for every release.

    appMarketingVersion = (defaultText = "1.8.18-1"),
    # Human-readable representation of appVersion. Should match the way you
    # identify versions of your app in documentation and marketing.

    actions = [
      # Define your "new document" handlers here.
      ( title = (defaultText = "New Etherpad Document"),
        nounPhrase = (defaultText = "pad"),
        command = .myCommand
        # The command to run when starting for the first time. (".myCommand"
        # is just a constant defined at the bottom of the file.)
      )
    ],

    continueCommand = .myCommand,
    # This is the command called to start your app back up after it has been
    # shut down for inactivity. Here we're using the same command as for
    # starting a new instance, but you could use different commands for each
    # case.

    metadata = (
      icons = (
        appGrid = (svg = embed "branding/app-graphics/etherpad-128.svg"),
        grain = (svg = embed "branding/app-graphics/etherpad-24.svg"),
        market = (svg = embed "branding/app-graphics/etherpad-150.svg"),
        marketBig = (svg = embed "branding/app-graphics/etherpad-300.svg"),
      ),

      website = "https://etherpad.org/",
      codeUrl = "https://github.com/sandstorm-org/etherpad-lite-sandstorm",
      license = (openSource = apache2),
      categories = [office, productivity],

      author = (
        contactEmail = "sandstorm-dev@googlegroups.com",
        pgpSignature = embed "pgp-signature",
        # PGP signature attesting responsibility for the app ID. This is a binary-format detached
        # signature of the following ASCII message (not including the quotes, no newlines, and
        # replacing <app-id> with the standard base-32 text format of the app's ID):
        #
        # "I am the author of the Sandstorm.io app with the following ID: <app-id>"
        #
        # You can create a signature file using `gpg` like so:
        #
        #     echo -n "I am the author of the Sandstorm.io app with the following ID: <app-id>" | gpg --sign > pgp-signature
        #
        # Further details including how to set up GPG and how to use keybase.io can be found
        # at https://docs.sandstorm.io/en/latest/developing/publishing-apps/#verify-your-identity

        upstreamAuthor = "Etherpad Foundation",
      ),

      pgpKeyring = embed "pgp-keyring",
      # A keyring in GPG keyring format containing all public keys needed to verify PGP signatures in
      # this manifest (as of this writing, there is only one: `author.pgpSignature`).
      #
      # To generate a keyring containing just your public key, do:
      #
      #     gpg --export <key-id> > keyring
      #
      # Where `<key-id>` is a PGP key ID or email address associated with the key.

      description = (defaultText = embed "branding/description.md"),
      shortDescription = (defaultText = "Document editor"),

      screenshots = [

        (width = 1280, height = 614, png = embed "branding/screenshots/screenshot-1.png"),
        (width = 1280, height = 614, png = embed "branding/screenshots/screenshot-2.png"),
      ],

      changeLog = (defaultText = embed "CHANGELOG.md"),
    ),
  ),

  sourceMap = (
    # Here we defined where to look for files to copy into your package. The
    # `spk dev` command actually figures out what files your app needs
    # automatically by running it on a FUSE filesystem. So, the mappings
    # here are only to tell it where to find files that the app wants.
    searchPath = [
      ( sourcePath = "rootfs" ),
      ( sourcePath = "." ),  # Search this directory first.
      ( sourcePath = "/",    # Then search the system root directory.
        hidePaths = [ "home", "proc", "sys",
                      "etc/passwd", "etc/hosts", "etc/host.conf",
                      "etc/nsswitch.conf", "etc/resolv.conf"
                    ]
        # You probably don't want the app pulling files from these places,
        # so we hide them. Note that /dev, /var, and /tmp are implicitly
        # hidden because Sandstorm itself provides them.
      ),
      ( sourcePath = "/opt/sandstorm/latest/usr/include",
        packagePath = "usr/include" )
    ]
  ),

  fileList = "sandstorm-files.list",
  # `spk dev` will write a list of all the files your app uses to this file.
  # You should review it later, before shipping your app.

  alwaysInclude = ["opt/app/etherpad-lite/src", "opt/app/etherpad-lite/node_modules", "opt/app/etherpad-lite/cache"],
  # Fill this list with more names of files or directories that should be
  # included in your package, even if not listed in sandstorm-files.list.
  # Use this to force-include stuff that you know you need but which may
  # not have been detected as a dependency during `spk dev`. If you list
  # a directory here, its entire contents will be included recursively.

  bridgeConfig = (
    viewInfo = (
      permissions = [(name = "modify", title = (defaultText = "modify"),
                      description = (defaultText = "allows modifying the document")),
                     (name = "comment", title = (defaultText = "comment"),
                      description = (defaultText = "allows adding comments"))],
      roles = [(title = (defaultText = "editor"),
                permissions = [true, true],
                verbPhrase = (defaultText = "can edit"),
                default = true),
               (title = (defaultText = "viewer"),
                permissions = [false, false],
                verbPhrase = (defaultText = "can view")),
               (title = (defaultText = "commenter"),
                permissions = [false, true],
                verbPhrase = (defaultText = "can comment"))],
      eventTypes = [
        (name = "edit", verbPhrase = (defaultText = "edited pad"),
            notifySubscribers = false, autoSubscribeToGrain = true),
        (name = "comment", verbPhrase = (defaultText = "added comment"),
            notifySubscribers = true, autoSubscribeToThread = true),
        (name = "reply", verbPhrase = (defaultText = "replied to comment"),
            notifySubscribers = true, autoSubscribeToThread = true)
      ],
    ),

    saveIdentityCaps = true,
  )
);

const myCommand :Spk.Manifest.Command = (
  # Here we define the command used to start up your server.
  argv = ["/sandstorm-http-bridge", "9001", "--", "/bin/bash", "/opt/app/.sandstorm/launcher.sh"],
  environ = [
    # Note that this defines the *entire* environment seen by your app.
    (key = "PATH", value = "/usr/local/bin:/usr/bin:/bin"),
    (key = "SANDSTORM", value = "1"),
  ]
);
