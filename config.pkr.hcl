packer {
    required_plugins {
        outscale = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/outscale"
        }
        windows-update = {
            version = ">=0.14.0"
            source = "github.com/rgl/windows-update"
        }
    }
}
