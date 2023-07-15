<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="${pknDao}.${ClassName}Mapper">
	<sql id="baseColumns">
		${columnFiles}
	</sql>

	<sql id="updateColumns">
		<set>
			${updateColumns}
		</set>
	</sql>

    <sql id="whereClause">
        <trim prefix="WHERE" prefixOverrides="AND">
			${whereColumns}
        </trim>
    </sql>

	<insert id="save" parameterType="${pknEntity}.${ClassName}">
		insert into ${tableName}
		(<include refid="saveColumn"/>)
		values
		(<include refid="saveValue"/>)
	</insert>

	<sql id="saveColumn">
		<trim suffixOverrides=",">
			${saveColumn}
		</trim>
	</sql>

	<sql id="saveValue">
		<trim suffixOverrides=",">
			${saveValue}
		</trim>
	</sql>

	<delete id="deleteById" parameterType="${pknEntity}.${ClassName}">
		DELETE FROM ${tableName} WHERE id = ${"#"}{id}
	</delete>

	<update id="updateById" parameterType="${pknEntity}.${ClassName}">
		update ${tableName}
		<include refid="updateColumns" />
		, version = version + 1
		where id = ${"#"}{id}
		and version = ${"#"}{version}
	</update>

	<select id="selectOne" resultType="${pknEntity}.${ClassName}" parameterType="${pknEntity}.${ClassName}">
		SELECT
		<include refid="baseColumns" />
		FROM ${tableName}
        <include refid="whereClause">
            <property name="columnPrefix" value=""/>
        </include>
	</select>

	<select id="selectByIndexCount" parameterType="${pknEntity}.${ClassName}" resultType="int">
		SELECT count(1)
		FROM ${tableName}
        <include refid="whereClause">
            <property name="columnPrefix" value=""/>
        </include>
	</select>

	<select id="selectByIndex" parameterType="${pknEntity}.${ClassName}" resultType="${pknEntity}.${ClassName}">
		SELECT
		<include refid="baseColumns" />
		FROM ${tableName}
        <include refid="whereClause">
            <property name="columnPrefix" value=""/>
        </include>
		<if test="sortBy != null and sortBy != '' and sortType != null and sortType != '' ">
			ORDER BY ${"$"}{sortBy} ${"$"}{sortType}
		</if>
		LIMIT ${"#"}{offset} , ${"#"}{limit}
	</select>
</mapper>
