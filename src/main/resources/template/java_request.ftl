package ${pknRequest};

import org.springframework.beans.BeanUtils;
import com.cyber.domain.entity.PagingRequest;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import ${pknEntity}.${ClassName};

@Getter
@Setter
@EqualsAndHashCode(callSuper = true)
public class ${ClassName}Request extends PagingRequest {
	
	${entityFeilds}
	
	public ${ClassName} toEvent(String tenantCode) {
		${ClassName} ${className} = new ${ClassName}();
		BeanUtils.copyProperties(this, ${className});
        ${className}.setTenantCode(tenantCode);
		return ${className};
	}
}