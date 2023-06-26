package	${pknServiceImpl};

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.cyber.domain.entity.PagingData;
import ${pknDao}.${ClassName}Mapper;
import ${pknEntity}.${ClassName};
import ${pknService}.${ClassName}Service;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ${ClassName}ServiceImpl implements ${ClassName}Service {

	private static final Logger LOGGER = LoggerFactory.getLogger( ${ClassName}ServiceImpl.class );

    private final ${ClassName}Mapper ${className}Mapper;

    @Override
    @Transactional
    public Integer save(${ClassName} ${className}) {

        if( null == ${className} ) {
            LOGGER.warn("save ${className}, but ${className} is null...");
            return 0;
        }

        return ${className}Mapper.save( ${className} );
    }

    @Override
    @Transactional
    public Integer deleteById(${ClassName} ${className}) {

        if( null == ${className} ) {
            LOGGER.warn("delete ${className}, but ${className} is null  or ${className} id is null...");
            return 0;
        }

        return ${className}Mapper.deleteById( ${className} );
    }

    @Override
    @Transactional
    public Integer updateById(${ClassName} ${className}) {

        if( null == ${className} ) {
            LOGGER.warn("update ${className}, but ${className} is null  or ${className} id is null...");
            return 0;
        }

        return ${className}Mapper.updateById( ${className} );
    }

    @Override
    public ${ClassName} selectOne(${ClassName} ${className}) {
        if( null == ${className} ) {
            LOGGER.warn("select ${className} one, but ${className} is null ...");
            return null;
        }
        ${className} = ${className}Mapper.selectOne( ${className} );
        return ${className};
    }
    

    @Override
    public PagingData<${ClassName}> selectPage(${ClassName} ${className}) {
        PagingData<${ClassName}> pagingData = new PagingData<>();

        if( null == ${className} ) {
            LOGGER.warn("select ${className} page, but ${className} is null...");
            return pagingData;
        }

        Integer queryCount = ${className}Mapper.selectByIndexCount( ${className} );
        pagingData.setRow( queryCount );

        if( queryCount <= 0 ) {
            LOGGER.info("select ${className} page , but count {} == 0 ...",queryCount);
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
            LOGGER.warn("select ${className} by index, but ${className} is null ...");
            return ${className}s;
        }

        ${className}s = ${className}Mapper.selectByIndex( ${className} );
        
        return ${className}s;
    }
}
