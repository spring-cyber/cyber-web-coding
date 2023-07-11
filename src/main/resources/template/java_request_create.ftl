package ${pknRequest};

import java.util.Date;
import org.springframework.beans.BeanUtils;
import com.cyber.domain.entity.OperateEntity;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import ${pknEntity}.${ClassName};

@Getter
@Setter
@EqualsAndHashCode(callSuper = true)
public class Create${ClassName}Request extends OperateEntity {

	${entityFeilds}

	public ${ClassName} toEvent(String userCode,String tenantCode) {
		${ClassName} ${className} = new ${ClassName}();
		BeanUtils.copyProperties(this, ${className});

        ${className}.setTenantCode(tenantCode);
        ${className}.setCreator(userCode);
		${className}.setCreateTime(new Date());

        ${className}.setUpdator(userCode);
		${className}.setUpdateTime(new Date());

		return ${className};
	}
}
