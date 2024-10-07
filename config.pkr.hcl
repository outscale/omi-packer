packer {
    required_plugins {
        outscale = {
            version = ">= 1.1.3"
            source  = "github.com/outscale/outscale"
        }
        windows-update = {
            version = ">=0.14.0"
            source = "github.com/rgl/windows-update"
        }
    }
}
