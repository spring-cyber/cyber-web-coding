package	${pknServiceImpl};

import java.util.ArrayList;
import java.util.List;

import com.cyber.domain.entity.PagingResponse;
import ${pknDao}.${ClassName}Mapper;
import ${pknEntity}.${ClassName};
import ${pknService}.${ClassName}Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ${ClassName}ServiceImpl implements ${ClassName}Service {

    private final ${ClassName}Mapper ${className}Mapper;

    @Override
    @Transactional
    public Integer save(${ClassName} ${className}) {

        if( null == ${className} ) {
            log.warn("save ${className}, but ${className} is null...");
            return 0;
        }

        return ${className}Mapper.save( ${className} );
    }

    @Override
    @Transactional
    public Integer deleteById(${ClassName} ${className}) {

        if( null == ${className} ) {
            log.warn("delete ${className}, but ${className} is null  or ${className} id is null...");
            return 0;
        }

        return ${className}Mapper.deleteById( ${className} );
    }

    @Override
    @Transactional
    public Integer updateById(${ClassName} ${className}) {

        if( null == ${className} ) {
            log.warn("update ${className}, but ${className} is null  or ${className} id is null...");
            return 0;
        }

        return ${className}Mapper.updateById( ${className} );
    }

    @Override
    public ${ClassName} selectOne(${ClassName} ${className}) {
        if( null == ${className} ) {
            log.warn("select ${className} one, but ${className} is null ...");
            return null;
        }
        ${className} = ${className}Mapper.selectOne( ${className} );
        return ${className};
    }


    @Override
    public PagingResponse<${ClassName}> selectPage(${ClassName} ${className}) {
        PagingResponse<${ClassName}> pagingData = new PagingResponse<>();

        if( null == ${className} ) {
            log.warn("select ${className} page, but ${className} is null...");
            return pagingData;
        }

        Integer queryCount = ${className}Mapper.selectByIndexCount( ${className} );
        pagingData.setRow( queryCount );

        if( queryCount <= 0 ) {
            log.info("select ${className} page , but count {} == 0 ...",queryCount);
            return pagingData;
        }

        List<${ClassName}> ${className}s =  selectByIndex( ${className} );
        pagingData.setData( ${className}s );
        return pagingData;
    }

    @Override
    public List<${ClassName}> selectByIndex(${ClassName} ${className}) {
        List<${ClassName}> ${className}s = new ArrayList<>();
        if( null == ${className} ) {
            log.warn("select ${className} by index, but ${className} is null ...");
            return ${className}s;
        }

        ${className}s = ${className}Mapper.selectByIndex( ${className} );

        return ${className}s;
    }
}
