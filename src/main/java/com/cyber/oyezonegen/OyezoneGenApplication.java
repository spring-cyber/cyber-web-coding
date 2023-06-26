package com.cyber.oyezonegen;

import com.alibaba.fastjson2.JSON;
import com.cyber.oyezonegen.config.DomainConfig;
import com.cyber.oyezonegen.config.GenConfig;
import com.cyber.oyezonegen.config.TableMapping;
import freemarker.template.Configuration;
import freemarker.template.Template;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.DefaultResourceLoader;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OyezoneGenApplication {

    private static Logger logger = LoggerFactory.getLogger(OyezoneGenApplication.class);


    private static String[] noneExitsColumn = {
            "id",
            "tenant_code",
            "creator_id",
            "create_time",
            "updator_id",
            "update_time",
            "deleted",
            "status",
            "remark",
            "version",
    "creator","updator"};


    private static String jdbcType = "mysql";
    private static String url = "jdbc:mysql://127.0.0.1:3306/oyezone?useUnicode=true&zeroDateTimeBehavior=convertToNull&autoReconnect=true&characterEncoding=utf-8";
    private static String userName = "root";
    private static String password = "root";
    private static String dbName = "oyezone";
    private static String domain;

    private static String packageName = "com.cyber." + domain;
    private static String projectName = "cyber-web-oyezone";

    private static GenConfig cfg;

    public static void main(String[] args) throws Exception{
        OyezoneGenApplication generate = new OyezoneGenApplication();
//        String[] classNames = new String[]{"Tenant","Product","Project","Permission","Role","User","UserExtension","Account","UserRole","Dept","ActivityLog"};
//        String[] tableNames = new String[]{"tenant","product","project","permission","role","user","user_extension","account","user_role","dept","activity_log"};
        String str = Files.readString(Paths.get(generate.getClass().getResource("/table.json").toURI()));
        cfg = JSON.parseObject(str, GenConfig.class);

//        String[] classNames = new String[]{"Agent", "AgentCertification", "AgentCertificationLog","AgentNFT"};
//        String[] tableNames = new String[]{"t_agent", "t_agent_certification", "t_agent_certification_log", "t_agent_nft"};
//        try {
//            if (classNames.length != tableNames.length) {
//                logger.error("classNames length {} not equal tableNames length {}", classNames.length, tableNames.length);
//                return;
//            }
//            for (int i = 0; i < classNames.length; i++) {
//                generate.gen(classNames[i], tableNames[i]);
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
        for (DomainConfig domainCfg: cfg.getDomains()) {
            domain = domainCfg.getDomain();
            packageName = cfg.getPackageName() + domain;
            logger.info("{} domain code gen, packetName  {}, projectPath {}", domain, packageName, cfg.getProjectPath());
            for (TableMapping mapping : domainCfg.getMappings()) {
                generate.gen(mapping.getClassName(), mapping.getTableName());
            }
        }

    }

    public void gen(String className, String tableName) throws Exception {
        if (StringUtils.isEmpty(className) || StringUtils.isEmpty(tableName)) {
            logger.error("className {} or tableName {} is empty...", className, tableName);
            return;
        }

        if (StringUtils.isEmpty(url) || StringUtils.isEmpty(userName) || StringUtils.isEmpty(password)
                || StringUtils.isEmpty(dbName)) {
            logger.error("参数设置错误：数据库URL、用户名、密码、数据库名不能为空。");
            return;
        }


        // 获取文件分隔符
        String separator = File.separator;

        // 获取工程路径
        File projectFile = new DefaultResourceLoader().getResource("").getFile();
        while (!new File(projectFile.getPath() + separator + "src").exists()) {
            projectFile = projectFile.getParentFile();
        }
        String projectPath = StringUtils.replace(projectFile + "", "houke-cloud-tools", projectName);
        logger.info("Project Path: {}", projectPath);

        // 模板文件路径
        String tplPath = projectPath + StringUtils.replace("/src/main/resources/template", "/", separator);
        logger.info("Template Path: {}", tplPath);

        // Java文件路径
        String javaPath = cfg.getProjectPath() + StringUtils.replaceEach("/src/main/java/" + StringUtils.lowerCase(packageName), new String[]{"/", "."}, new String[]{separator, separator});
        logger.info("Java Path: {}", javaPath);

        // Mybatis Mapper文件路径
        String mapperPath = cfg.getProjectPath() + StringUtils.replace("/src/main/resources/mapper/", "/", separator);
        logger.info("Mapper Path: {}", mapperPath);

        // VUE文件路径
        String vuePath = cfg.getProjectPath() + StringUtils.replace("/src/main/resources/vue/", "/", separator);
        logger.info("Vue Path: {}", vuePath);

        // 代码模板配置
        Configuration cfg = new Configuration(Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS);
        cfg.setDirectoryForTemplateLoading(new File(tplPath));

        // 定义模板变量
        Map<String, Object> model = new HashMap<String, Object>();
        model.put("packageName", StringUtils.lowerCase(packageName));

        model.put("classname", className.toLowerCase());
        model.put("className", StringUtils.uncapitalize(className));
        model.put("ClassName", StringUtils.capitalize(className));
        model.put("tableName", tableName);
        model.put("jdbcType", jdbcType);

        GenerateEntity createEntity = new GenerateEntity(jdbcType, url, userName, password, dbName);
        List<Map<String, String>> columnList = createEntity.getColumnDatas(tableName);
        String updateColumns = createEntity.getUpdateColumns(columnList);
        String whereColumns = createEntity.getWhereColumns(columnList);
        model.put("entityFeilds", createEntity.getBeanFeilds(tableName, noneExitsColumn));
        model.put("columnFiles", createEntity.getColumnField(columnList));
        model.put("updateColumns", updateColumns);
        model.put("whereColumns", whereColumns);
        model.put("insertSQL", createEntity.getInsertColumns(columnList));
        model.put("saveColumn", createEntity.getSaveColumn(columnList));
        model.put("saveValue", createEntity.getSaveValue(columnList));
        model.put("indexTableHead", createEntity.getIndexTableHead(columnList));
        model.put("indexTableBody", createEntity.getIndexTableBody(columnList));
        model.put("editFormInput", createEntity.getEditFormInput(columnList));
        model.put("columnList", createEntity.getTableFeilds(columnList));

        model.put("pknEntity", packageName + "." +"domain" + "." + "entity");
        model.put("pknRequest", packageName + "." + "domain" + "." + "request");
        model.put("pknDao", packageName +  "." + "domain" + "." + "repository");
        model.put("pknService", packageName + "." + "application");
        model.put("pknServiceImpl", packageName + "." + "application.impl");
        model.put("pknRest", packageName + "." + "presentation.rest");
        model.put("pknWeb", packageName + "." + model.get("classname").toString());

        model.put("requestMapping", StringUtils.capitalize(className));


        // 生成 Entity
        Template template = cfg.getTemplate("java_entity.ftl");
        String content = renderTemplate(template, model);
        String filePath = javaPath + separator + "domain" + separator + "entity" + separator  + model.get("ClassName") + ".java";
        writeFile(content, filePath);
        logger.info("Entity: {}", filePath);

        // 生成Dao
        template = cfg.getTemplate("java_mapper.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator +  "domain" + separator + "repository" + separator + model.get("ClassName") + "Mapper.java";
        writeFile(content, filePath);
        logger.info("Dao: {}", filePath);

        // 生成Mapper
        template = cfg.getTemplate("xml_mapper.ftl");
        content = renderTemplate(template, model);
        filePath = mapperPath + separator + model.get("ClassName") + "Mapper.xml";
        writeFile(content, filePath);
        logger.info("Mapper: {}", filePath);

        // 生成Service
        template = cfg.getTemplate("java_service.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator + "application" + separator + model.get("ClassName") + "Service.java";
        writeFile(content, filePath);
        logger.info("Service: {}", filePath);

        // 生成ServiceImpl
        template = cfg.getTemplate("java_service_impl.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator + "application" + separator + "impl" + separator + model.get("ClassName")
                + "ServiceImpl.java";
        writeFile(content, filePath);
        logger.info("Dao: {}", filePath);

        // 生成Rest
        template = cfg.getTemplate("java_rest.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator  + "presentation" + separator + "rest" + separator + model.get("ClassName") + "Rest.java";
        writeFile(content, filePath);
        logger.info("controller: {}", filePath);

        // 生成 Request
        template = cfg.getTemplate("java_request.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator + "domain" + separator + "request" + separator + model.get("ClassName") + "Request.java";
        writeFile(content, filePath);
        logger.info("Entity: {}", filePath);


        // 生成 CreateRequest
        template = cfg.getTemplate("java_request_create.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator + "domain" + separator + "request" + separator + "Create" + model.get("ClassName") + "Request.java";
        writeFile(content, filePath);
        logger.info("Entity: {}", filePath);

        // 生成 Request
        template = cfg.getTemplate("java_request_update.ftl");
        content = renderTemplate(template, model);
        filePath = javaPath + separator + "domain" + separator + "request" + separator + "Update" + model.get("ClassName") + "Request.java";
        writeFile(content, filePath);
        logger.info("Entity: {}", filePath);

        // 生成 Vue
        template = cfg.getTemplate("view.ftl");
        content = renderTemplate(template, model);
        filePath = vuePath + separator + model.get("ClassName") + ".vue";
        writeFile(content, filePath);
        logger.info("Vue: {}", filePath);
    }

    public static void writeFile(String content, String filePath) {
        try {
            if (createFile(filePath)) {
                FileWriter fileWriter = new FileWriter(filePath, true);
                BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
                bufferedWriter.write(content);
                bufferedWriter.close();
                fileWriter.close();
            } else {
                logger.info("生成失败，文件已存在！");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String renderTemplate(Template template, Object model) {
        try {
            StringWriter result = new StringWriter();
            template.process(model, result);
            return result.toString();
        } catch (Exception e) {
            return null;
        }
    }

    public static boolean createFile(String descFileName) {
        File file = new File(descFileName);
        if (file.exists()) {
            logger.debug("文件 " + descFileName + " 已存在!");
            return false;
        }
        if (descFileName.endsWith(File.separator)) {
            logger.debug(descFileName + " 为目录，不能创建目录!");
            return false;
        }
        if (!file.getParentFile().exists()) {
            // 如果文件所在的目录不存在，则创建目录
            if (!file.getParentFile().mkdirs()) {
                logger.debug("创建文件所在的目录失败!");
                return false;
            }
        }

        // 创建文件
        try {
            if (file.createNewFile()) {
                logger.debug(descFileName + " 文件创建成功!");
                return true;
            } else {
                logger.debug(descFileName + " 文件创建失败!");
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.debug(descFileName + " 文件创建失败!");
            return false;
        }

    }
}