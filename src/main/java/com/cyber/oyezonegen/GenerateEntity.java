package com.cyber.oyezonegen;

import org.apache.commons.lang3.StringUtils;

import java.sql.*;
import java.util.*;

public class GenerateEntity {

	private static String jdbcType;
	private static String url;
	private static String userName;
	private static String password;
	private static String dbName;

	public GenerateEntity(String jdbcType, String url, String userName, String password, String dbName ) {
		this.jdbcType = jdbcType;
		this.url = url;
		this.userName = userName;
		this.password = password;
		this.dbName = dbName;
	}

	public Connection getConnection() throws SQLException {
		return DriverManager.getConnection( url, userName, password );
	}

	public List<Map<String, String>> getColumnDatas( String tableName ) throws SQLException {
		String sqlColumns = "SELECT distinct COLUMN_NAME, DATA_TYPE, COLUMN_COMMENT,ORDINAL_POSITION FROM information_schema.COLUMNS "
				+ " WHERE table_name = '" + tableName + "' and table_schema='" + dbName + "' ORDER BY ORDINAL_POSITION ASC";// Mysql
		Connection conn = this.getConnection();
		PreparedStatement ps = conn.prepareStatement( sqlColumns );

		List<Map<String, String>> columnList = new ArrayList<Map<String, String>>();
		ResultSet rs = ps.executeQuery();
		Map<String, String> columnData = null;
		while( rs.next() ) {
			String name = rs.getString( 1 );
			String type = rs.getString( 2 );
			String comment = rs.getString( 3 );
			type = this.getType( type );

			if( "_id".equals( name ) ) {
				continue;
			}

			columnData = new HashMap<String, String>();
			columnData.put( "columnName", name.toLowerCase() );
			columnData.put( "dataType", type);
			columnData.put( "columnComment", StringUtils.isEmpty(comment)?null:(comment.contains("|")?comment.replace("|"," "):comment) );
			columnData.put( "columnTitle", StringUtils.isEmpty(comment)?null:(comment.contains("|")?comment.split("\\|")[0]:comment) );
			columnList.add( columnData );
		}
		rs.close();
		ps.close();
		conn.close();
		return columnList;
	}

	public String getType( String type ) {
		type = type.toLowerCase();
		if( "char".equals( type ) || "varchar".equals( type ) || "varchar2".equals( type )  || "text".equals( type ) ) {
			return "String";
		} else if( "int".equals( type ) || "smallint".equals( type ) || "tinyint".equals( type ) ) {
			return "Integer";
		} else if( "bigint".equals( type ) ) {
			return "Long";
		} else if( "timestamp".equals( type ) || "timestamp(6)".equals( type ) || "date".equals( type )
				|| "datetime".equals( type ) ) {
			return "java.util.Date";
		} else if( "double".equals( type ) ) {
			return "Double";
		} else if( "decimal".equals( type ) ) {
			return "java.math.BigDecimal";
		}
		return "String";
	}

	public String getBeanFeilds( String tableName,String[] noneExitsColumn ) throws SQLException {
		List<Map<String, String>> columnList = getColumnDatas( tableName );
		StringBuffer field = new StringBuffer();
		StringBuffer getset = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String dataType = column.get( "dataType" );
			String columnComment = column.get( "columnComment" );

			if( Arrays.asList( noneExitsColumn ).contains( columnName ) ) {
				continue;
			}

			if( columnName.contains( "_" ) ) {
				columnName = getBeanName( columnName );
			}

			field.append( "\r\t" ).append("/**").append( columnComment ).append("*/");
			field.append( "\r\t" ).append( "private " ).append( dataType + " " ).append( columnName ).append( ";" );
//			getset.append( "\r\t" ).append( "public " ).append( dataType + " " ).append( "get" + StringUtils.capitalize( columnName ) + "() {\r\t" );
//			getset.append( "    return this." ).append( columnName ).append( ";\r\t}" );
//			getset.append( "\r\t" ).append( "public void " ).append("set" + StringUtils.capitalize( columnName ) + "(" + dataType + " " + columnName + ") {\r\t" );
//			getset.append( "    this." + columnName + " = " ).append( columnName ).append( ";\r\t}" );
		}
//		return field.toString()  + getset;
		return field.toString();
	}

	public String getColumnField( List<Map<String, String>> columnList ) {
		StringBuffer field = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			field.append( " " ).append( column.get( "columnName" ) ).append( "," );
		}
		String columnFiles = field.toString();
		return columnFiles.endsWith( "," ) ? field.toString().substring( 0, columnFiles.length() - 1 ) : columnFiles;
	}

	public String getUpdateColumns( List<Map<String, String>> columnList ) {
		StringBuffer field = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String beanName = getBeanName( columnName );

			field.append( "  <if test=" ).append( "\"" ).append( beanName ).append( " != null" ).append( "\">" )
					.append( "\r\t" );
			field.append( columnName ).append( "   = #{" ).append( beanName ).append( "}," ).append( "\r" );
			field.append( "  </if>" ).append( "\r" );
		}
		return field.toString();
	}

	public String getWhereColumns( List<Map<String, String>> columnList ) {
		StringBuffer field = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			if ("version".equals(columnName)) continue;
			String beanName = getBeanName( columnName );

			field.append( "  <if test=" ).append( "\"" ).append( beanName ).append( " != null" ).append( "\">" )
					.append( "\r\t" );
			field.append( "    AND ${columnPrefix}" ).append( columnName ).append( " = #{" ).append( beanName ).append( "}" ).append( "\r" );
			field.append( "  </if>" ).append( "\r" );
		}
		return field.toString();
	}

	public String getInsertColumns( List<Map<String, String>> columnList ) {
		StringBuffer field = new StringBuffer();
		StringBuffer baseColumns = new StringBuffer();
		StringBuffer baseBeans = new StringBuffer();

		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String beanName = getBeanName( columnName );

			baseColumns.append( " " ).append( columnName ).append( "," );
			baseBeans.append( " #{" ).append( beanName ).append( "}," ).append( "\r" );
		}
		String baseColumn = baseColumns.toString();
		String baseBean = baseBeans.toString();
		if( baseColumn.endsWith( "," ) ) {
			baseColumn = baseColumn.substring( 0, baseColumn.length() - 1 );
		}
		if( baseBean.endsWith( ",\r" ) ) {
			baseBean = baseBean.substring( 0, baseBean.length() - 2 );
		}
		field.append( "(" ).append( baseColumn ).append( ")" ).append( "\r" );
		field.append( " values " ).append( "\r" );
		field.append( "(" ).append( baseBean ).append( ")" );
		return field.toString();
	}

	public String getSaveColumn(List<Map<String, String>> columnList){
		StringBuffer field = new StringBuffer();
		StringBuffer baseColumns = new StringBuffer();
		StringBuffer baseBeans = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String beanName = getBeanName( columnName );
			baseColumns.append( "<if test=\"" ).append( beanName ).append( "!= null\">" ).append(columnName).append(",</if>").append( "\r" );
		}
		return baseColumns.toString();
	}
	public String getSaveValue(List<Map<String, String>> columnList){
		StringBuffer field = new StringBuffer();
		StringBuffer baseColumns = new StringBuffer();
		StringBuffer baseBeans = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String beanName = getBeanName( columnName );
			baseColumns.append( "<if test=\"" ).append( beanName ).append( "!= null\">#{" ).append(beanName).append("},</if>").append( "\r" );
		}
		return baseColumns.toString();
	}

	public String getBeanName( String columnName ) {
		StringBuffer beanName = new StringBuffer();
		String[] str = columnName.split( "_" );
		for( int i = 0, len = str.length; i < len; i++ ) {
			if( i == 0 ) {
				beanName.append( str[ i ] );
			} else {
				beanName.append( StringUtils.capitalize( str[ i ] ) );
			}
		}
		return beanName.toString();
	}
	
	public String getIndexTableHead(List<Map<String, String>> columnList ){
		StringBuffer tableHead = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnTitle = column.get( "columnTitle" );
			tableHead.append( "                        <th width=\"84px\">").append(columnTitle).append("</th>").append( "\r" );
		}
		return tableHead.toString();
	}
	
	public String getIndexTableBody(List<Map<String, String>> columnList ){
		StringBuffer tableBody = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			if( columnName.contains( "_" ) ) {
				columnName = getBeanName( columnName );
			}
			tableBody.append( "    <td>{{"+columnName+"}}</td>").append( "\r" );
		}
		return tableBody.toString();
	}
	
	public String getEditFormInput(List<Map<String, String>> columnList ){
		StringBuffer tableBody = new StringBuffer();
		for( Map<String, String> column : columnList ) {
			String columnTitle = column.get( "columnTitle" );
			String columnName = column.get( "columnName" );
			
			if(columnName.equals("id")){
				tableBody.append( "             <input type=\"hidden\" placeholder=\""+columnTitle+"\" name=\""+columnName+"\" > ").append( "\r" );
			}else{
				
				if( columnName.contains( "_" ) ) {
					columnName = getBeanName( columnName );
				}
	            
				tableBody.append( "            <div class=\"form-group col-md-4\">").append( "\r" );
				tableBody.append( "             <label>"+columnTitle+"</label> ").append( "\r" );
				tableBody.append( "             <input type=\"text\" placeholder=\""+columnTitle+"\" name=\""+columnName+"\" class=\"form-control\"> ").append( "\r" );
				tableBody.append( "             </div>").append( "\r" );
			}

		}
		return tableBody.toString();
	}

	public List<Map<String, String>> getTableFeilds(List<Map<String, String>> columnList) {
		for( Map<String, String> column : columnList ) {
			String columnName = column.get( "columnName" );
			String columnComment = column.get( "columnComment" );
			if( columnName.contains( "_" ) ) {
				columnName = getBeanName( columnName );
			}
			if (StringUtils.isBlank(columnComment)) {
				column.put("columnComment", columnName);
			}
			column.put("columnName", columnName);
		}
		return columnList;
	}
}
