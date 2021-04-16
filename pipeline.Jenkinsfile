import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper

def volume_size = "10"
switch(OS) {
    case "CentOS 8":
        base_name = "CentOS-8"
        script_base = "centos8"
        break

    case "CentOS 7":
        base_name = "CentOS-7"
        script_base = "centos7"
        break

    case "RHEL 7 BYOL":
        base_name = "RHEL-7-BYOL"
        script_base = "rhel7"
        break

    case "RHEL 8 BYOL":
        base_name = "RHEL-8-BYOL"
        script_base = "rhel8"
        break

    case "Ubuntu 18.04":
        base_name = "Ubuntu-18.04"
        script_base = "ubuntu1804"
        break

    case "Ubuntu 20.04":
        base_name = "Ubuntu-20.04"
        script_base = "ubuntu2004"
        break

    case "Oracle Linux 7":
        base_name = "OracleLinux-7"
        script_base = "oracle7"
        volume_size = "15"
        break

    case "Debian 10":
        base_name = "Debian-10"
        script_base = "debian10"
        break
}

def source_omi = [
    "eu-west-2": "ami-9d4e6d52",
    "us-east-2": "ami-9f4e638d",
    "us-west-1": "ami-f738d199",
    "ap-northeast-1": "ami-88a0560e",
    "in-west-1": "",
    "in-west-2": "",
    "cloudgouv-eu-west-1": "ami-73bceeed",
    "cloudgouv-eu-west-2": "ami-df27cb3a",
    "top-west-1": "",
    "dv-west-1": ""
]
def endpoint = [
    "eu-west-2": "fcu.eu-west-2.outscale.com",
    "us-east-2": "fcu.us-east-2.outscale.com",
    "us-west-1": "fcu.us-west-1.outscale.com",
    "ap-northeast-1": "fcu.ap-northeast-1.outscale.com",
    "in-west-1": "fcu.in-west-1.outscale.com",
    "in-west-2": "fcu.in-west-2.outscale.com",
    "cloudgouv-eu-west-1": "fcu.cloudgouv-eu-west-1.outscale.com",
    "cloudgouv-eu-west-2": "fcu.cloudgouv-eu-west-2.outscale.com",
    "top-west-1": "fcu.top-west-1.outscale.com",
    "dv-west-1": "fcu.dv-west-1.outscale.com"
]
def api_endpoint = [
    "eu-west-2": "api.eu-west-2.outscale.com",
    "us-east-2": "api.us-east-2.outscale.com",
    "us-west-1": "api.us-west-1.outscale.com",
    "ap-northeast-1": "api.ap-northeast-1.outscale.com",
    "in-west-1": "api.in-west-1.outscale.com",
    "in-west-2": "api.in-west-2.outscale.com",
    "cloudgouv-eu-west-1": "api.cloudgouv-eu-west-1.outscale.com",
    "cloudgouv-eu-west-2": "api.cloudgouv-eu-west-2.outscale.com",
    "top-west-1": "api.top-west-1.outscale.com",
    "dv-west-1": "api.dv-west-1.outscale.com"
]

def branches = [:]
def qa_branches = [:]
def buildLogs = [:]

for (region in REGIONS.tokenize(",")) {
    def currentRegion = region
    branches["omi_${region}"] = {
        withCredentials([usernamePassword(credentialsId: 'api_osc-omi_' + currentRegion, usernameVariable: 'OSC_ACCESS_KEY', passwordVariable: 'OSC_SECRET_KEY')]) {
            build(job: 'build-linux-omi', parameters: [
                string(name: 'OUTSCALE_ACCESSKEYID', value: OSC_ACCESS_KEY),
                string(name: 'OUTSCALE_SECRETKEYID', value: OSC_SECRET_KEY),
                string(name: 'OUTSCALE_REGION', value: currentRegion),
                string(name: 'BASE_NAME', value: base_name),
                string(name: 'SCRIPT_BASE', value: script_base),
                string(name: 'SOURCE_OMI', value: source_omi[currentRegion]),
                string(name: 'ENDPOINT', value: endpoint[currentRegion]),
                string(name: 'OVERRIDE_NAME', value: OVERRIDE_NAME),
                string(name: 'BRANCH', value: BRANCH),
                string(name: 'VOL_SIZE', value: volume_size)
            ])
        }
    }
}

stage ("build_omi") {
    parallel branches
}

if (BRANCH != 'master') {
    currentBuild.result = 'SUCCESS'
    return
}

stage ("package_list") {
    node {
        for (region in REGIONS.tokenize(",")) {
            def currentRegion = region
            CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
            PACKAGE_LIST = sh(script: "echo /usr/local/packer/logs/packages/${CUR_OMI_NAME}", returnStdout: true).trim()
            echo PACKAGE_LIST

            build(job: 'push-package', parameters: [
                string(name: 'REGION', value: currentRegion),
                string(name: 'BRANCH', value: base_name),
                string(name: 'OMI_NAME', value: CUR_OMI_NAME),
                string(name: 'PACKAGE_LIST', value: PACKAGE_LIST)
            ])
        }
    }
}

stage ("omi_names") {
    node {
        for (region in REGIONS.tokenize(",")) {
            def currentRegion = region
            CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
            CUR_OMI_IMGNAME = sh(script: "readlink -f /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true)
            echo "${currentRegion}: ${CUR_OMI_NAME} (${CUR_OMI_IMGNAME})"
        }
    }
}

for (region in REGIONS.tokenize(",")) {
    def currentRegion = region
    def currentEndpoint = "https://" + api_endpoint[region] + "/api/latest"

    qa_branches["qa_${region}"] = {
        node {
            def CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
            build(job: 'qai-omi-linux', parameters: [
                string(name: 'OUTSCALE_REGION', value: currentRegion),
                string(name: 'TF_VAR_endpoint', value: currentEndpoint),
                string(name: 'TF_VAR_image_id', value: CUR_OMI_NAME),
                string(name: 'OS', value: base_name)
            ])
        }
    }
}

stage ("qa_omi") {
    parallel qa_branches
}

stage ("deploy_approval") {
    input "Publish OMI ?"
}

stage ("publish_omi") {
    node {
        for (region in REGIONS.tokenize(",")) {
            def currentRegion = region
            CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()

            withCredentials([usernamePassword(credentialsId: 'api_osc-omi_' + currentRegion, usernameVariable: 'OSC_ACCESS_KEY', passwordVariable: 'OSC_SECRET_KEY')]) {
                build(job: 'publish-omi', parameters: [
                    string(name: 'OSC_ACCESS_KEY', value: OSC_ACCESS_KEY),
                    string(name: 'OSC_SECRET_KEY', value: OSC_SECRET_KEY),
                    string(name: 'REGION', value: currentRegion),
                    string(name: 'OMI_ID', value: CUR_OMI_NAME),
                    string(name: 'ENDPOINT', value: endpoint[currentRegion])
                ])
            }
        }
    }
}
