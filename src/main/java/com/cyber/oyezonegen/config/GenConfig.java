package com.cyber.oyezonegen.config;

import java.util.List;

public class GenConfig {
    private String projectPath;

    private String packageName;

    private List<DomainConfig> domains;

    public String getProjectPath() {
        return projectPath;
    }

    public void setProjectPath(String projectPath) {
        this.projectPath = projectPath;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public List<DomainConfig> getDomains() {
        return domains;
    }

    public void setDomains(List<DomainConfig> domains) {
        this.domains = domains;
    }
}
