package ${pknRest};

import java.util.Date;
import javax.validation.Valid;


import org.springframework.context.annotation.Scope;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.bind.annotation.*;
import com.cyber.domain.entity.DataResponse;
import com.cyber.domain.entity.IdRequest;
import com.cyber.domain.entity.PagingResponse;
import com.cyber.domain.entity.Response;

import lombok.RequiredArgsConstructor;

import ${pknEntity}.${ClassName};
import ${pknRequest}.${ClassName}Request;
import ${pknRequest}.Create${ClassName}Request;
import ${pknRequest}.Update${ClassName}Request;

import ${pknService}.${ClassName}Service;

@RestController
@RequiredArgsConstructor
public class ${ClassName}Rest {

	private final ${ClassName}Service ${className}Service;

	@GetMapping("/${classname}/search")
	public Response search${ClassName}(@Valid ${ClassName}Request request) {
		DataResponse<PagingResponse<${ClassName}>> response = new DataResponse<>();
        ${ClassName}  ${classname} = request.toEvent(request.getTenantCode());
		PagingResponse<${ClassName}> ${className}Page = ${className}Service.selectPage(${classname});
		response.setData(${className}Page);
		return response;
	}


	@GetMapping("/${classname}")
	public Response selectOne${ClassName}(@Valid IdRequest idRequest) {
		DataResponse<${ClassName}> response = new DataResponse<>();

		${ClassName} ${className} = new ${ClassName}();
		${className}.setId(idRequest.getId());
        ${className}.setTenantCode(idRequest.getTenantCode());
		${className} = ${className}Service.selectOne(${className});

		response.setData(${className});
		return response;
	}

	@PostMapping("/${classname}")
	public Response save${ClassName}(@RequestBody @Valid Create${ClassName}Request request) {
	    ${ClassName}  ${classname} = request.toEvent(AuthenticationUtil.getUserCode(),request.getTenantCode());

		int result = ${className}Service.save(${classname});
		if (result < 1) {
			return Response.fail(HttpResultCode.SERVER_ERROR);
		}
		return Response.success();
	}

	@PutMapping("/${classname}")
	public Response update${ClassName}(@RequestBody @Valid Update${ClassName}Request request) {
	    ${ClassName}  ${classname} = request.toEvent(AuthenticationUtil.getUserCode(),request.getTenantCode());
		int result = ${className}Service.updateById(${classname});
		if (result < 1) {
			return Response.fail(HttpResultCode.SERVER_ERROR);
		}
		return Response.success();
	}

	@DeleteMapping("/${classname}")
	public Response delete${ClassName}(@Valid IdRequest idRequest) {
		${ClassName} ${className} = new ${ClassName}();
		${className}.setId(idRequest.getId());

		${className}.setTenantCode(idRequest.getTenantCode());
		${className}.setUpdator(AuthenticationUtil.getUserCode());
        ${className}.setUpdateTime(new Date());

		int result = ${className}Service.deleteById(${className});
		if (result < 1) {
			return Response.fail(HttpResultCode.SERVER_ERROR);
		}
		return Response.success();
	}
}
