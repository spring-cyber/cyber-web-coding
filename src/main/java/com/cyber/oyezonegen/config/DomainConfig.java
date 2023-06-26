package com.cyber.oyezonegen.config;

import java.util.List;

public class DomainConfig {
    private String domain;
    private List<TableMapping> mappings;

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public List<TableMapping> getMappings() {
        return mappings;
    }

    public void setMappings(List<TableMapping> mappings) {
        this.mappings = mappings;
    }
}
