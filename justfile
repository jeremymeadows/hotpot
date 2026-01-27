# Justfile for Hotpot project

# project metadata
name := "hotpot"
version := "1.0.0"

# deployment configuration
user := "root"
remote_host := "vps.jeremymeadows.dev"
identity_key := "~/.ssh/vps"
app_root := "/srv/sites/hotpot"

alias b := build
alias d := deploy

[private]
default:
    @just --list --unsorted

[private]
build-server:
    godot --headless --export-release Server

[private]
build-web:
    godot --headless --export-release Web

[private]
build-linux:
    godot --headless --export-release "Linux Desktop"

[private]
build-windows:
    godot --headless --export-release "Windows Desktop"

[private]
build-appimage: build-linux
    #!/bin/sh

    mkdir -p build/AppDir/usr/bin
    cp build/bin/{{name}}-linux-x86_64 build/AppDir/usr/bin/{{name}}-linux-x86_64

    cat > build/AppDir/{{name}}.desktop << EOF
    [Desktop Entry]
    Type=Application
    Name=Hotpot
    Exec={{name}}-linux-x86_64
    Icon={{name}}
    Categories=Game;
    EOF

    cat > build/AppDir/Apprun << EOF
    #!/bin/sh
    exec \$APPDIR/usr/bin/{{name}}-linux-x86_64
    EOF
    chmod +x build/AppDir/AppRun

    inkscape icon.svg -w 256 -h 256 -o build/AppDir/{{name}}.png
    appimagetool build/AppDir build/bin/{{name}}-x86_64.appimage


# Build all targets
build: build-server build-web build-linux build-windows build-appimage
    :


# Build and tag Docker image
dockerize: build-server
    docker build -t {{name}}-server:latest .
    docker image tag {{name}}-server:{{version}} {{name}}-server:latest


# Deploy to remote server
deploy: dockerize build-web
    #!/bin/sh

    docker image save {{name}}-server:{{version}} | ssh -i {{identity_key}} {{user}}@{{remote_host}} "docker image load"
    scp -i {{identity_key}} build/web/* docker-compose.yaml {{user}}@{{remote_host}}:{{app_root}}/
    ssh -i {{identity_key}} {{user}}@{{remote_host}} << END
        cd {{app_root}}
        docker image tag $name:$version $name:latest
        docker compose down
        docker compose up -d
    END

    echo "Deployed {{name}}:{{version}} to {{remote_host}}."