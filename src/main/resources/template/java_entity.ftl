package ${pknEntity};

import com.cyber.domain.entity.PagingEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class ${ClassName} extends PagingEntity {

	${entityFeilds}
}