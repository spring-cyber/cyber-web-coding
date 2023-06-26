package ${pknRest};

import java.util.Date;
import javax.validation.Valid;

import com.cyber.application.controller.AuthingTokenController;

import org.springframework.context.annotation.Scope;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.bind.annotation.*;
import com.cyber.domain.entity.DataResponse;
import com.cyber.domain.entity.IdRequest;
import com.cyber.domain.entity.PagingData;
import com.cyber.domain.entity.Response;

import lombok.RequiredArgsConstructor;

import ${pknEntity}.${ClassName};
import ${pknRequest}.${ClassName}Request;
import ${pknRequest}.Create${ClassName}Request;
import ${pknRequest}.Update${ClassName}Request;

import ${pknService}.${ClassName}Service;

@RestController
@RequiredArgsConstructor
@Scope(WebApplicationContext.SCOPE_REQUEST)
public class ${ClassName}Rest extends AuthingTokenController {

	private final ${ClassName}Service ${className}Service;

	@GetMapping("/${classname}/search")
	public Response search${ClassName}(@Valid ${ClassName}Request request) {
		DataResponse<PagingData<${ClassName}>> response = new DataResponse<>();
        ${ClassName}  ${classname} = request.toEvent(getTenantCode());
		PagingData<${ClassName}> ${className}Page = ${className}Service.selectPage(${classname});
		response.setData(${className}Page);
		return response;
	}

	
	@GetMapping("/${classname}")
	public Response selectOne${ClassName}(@Valid IdRequest idRequest) {
		DataResponse<${ClassName}> response = new DataResponse<>();

		${ClassName} ${className} = new ${ClassName}();
		${className}.setId(idRequest.getId());
        ${className}.setTenantCode(getTenantCode());
		${className} = ${className}Service.selectOne(${className});
		
		response.setData(${className});
		return response;
	}
	
	@PostMapping("/${classname}")
	public Response save${ClassName}(@RequestBody @Valid Create${ClassName}Request request) {
	    ${ClassName}  ${classname} = request.toEvent(getSessionId(),getTenantCode());

		${className}Service.save(${classname});
		return new Response();
	}

	@PutMapping("/${classname}")
	public Response update${ClassName}(@RequestBody @Valid Update${ClassName}Request request) {
	    ${ClassName}  ${classname} = request.toEvent(getSessionId(),getTenantCode());
		${className}Service.updateById(${classname});
		return new Response();
	}

	@DeleteMapping("/${classname}")
	public Response delete${ClassName}(@Valid IdRequest idRequest) {
		${ClassName} ${className} = new ${ClassName}();
		${className}.setId(idRequest.getId());

		${className}.setTenantCode(getTenantCode());
		${className}.setUpdatorId(getSessionId());
        ${className}.setUpdateTime(new Date());

		${className}Service.deleteById(${className});
		return new Response();
	}
}
