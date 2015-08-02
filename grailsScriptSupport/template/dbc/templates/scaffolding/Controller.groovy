package com.lj.dbc<%=apppkg ? ".${apppkg}\n\n" : '\n\n'%>

import org.springframework.dao.DataIntegrityViolationException
import grails.converters.JSON

<%=packageName ? "import ${packageName}.${className}\n" : ''%>

class ${className}Controller {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index() {
        redirect(action: "list", params: params)
    }

    def list(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        render(view:"/dbc/${className}/list",model:[${propertyName}List: ${className}.list(params), ${propertyName}Total: ${className}.count()])
    }

    def create() {
        render(view:"/dbc/${className}/create",model:[${propertyName}: new ${className}(params)])
    }

    def save() {
        def ${propertyName} = new ${className}(params)
        if (!${propertyName}.save(flush: true)) {
            render(view: "/dbc/${className}/create", model: [${propertyName}: ${propertyName}])
            return
        }

        flash.message = message(code: 'default.created.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.id])
        redirect(action: "show", id: ${propertyName}.id)
    }

    def show(Long id) {
        def ${propertyName} = ${className}.get(id)
        if (!${propertyName}) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "list")
            return
        }

        render(view:"/dbc/${className}/show",model:[${propertyName}: ${propertyName}])
    }

    def edit(Long id) {
        def ${propertyName} = ${className}.get(id)
        if (!${propertyName}) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "list")
            return
        }

        render(view:"/dbc/${className}/edit",model:[${propertyName}: ${propertyName}])
    }

    def update(Long id, Long version) {
        def ${propertyName} = ${className}.get(id)
        if (!${propertyName}) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "list")
            return
        }

        if (version != null) {
            if (${propertyName}.version > version) {<% def lowerCaseName = grails.util.GrailsNameUtils.getPropertyName(className) %>
                ${propertyName}.errors.rejectValue("version", "default.optimistic.locking.failure",
                          [message(code: '${domainClass.propertyName}.label', default: '${className}')] as Object[],
                          "Another user has updated this ${className} while you were editing")
                render(view: "/dbc/${className}/edit", model: [${propertyName}: ${propertyName}])
                return
            }
        }

        ${propertyName}.properties = params

        if (!${propertyName}.save(flush: true)) {
            render(view: "/dbc/${className}/edit", model: [${propertyName}: ${propertyName}])
            return
        }

        flash.message = message(code: 'default.updated.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.id])
        redirect(action: "show", id: ${propertyName}.id)
    }

    def delete(Long id) {
        def ${propertyName} = ${className}.get(id)
        if (!${propertyName}) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "list")
            return
        }

        try {
            ${propertyName}.delete(flush: true)
            flash.message = message(code: 'default.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "list")
        }
        catch (DataIntegrityViolationException e) {
            flash.message = message(code: 'default.not.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
            redirect(action: "show", id: id)
        }
    }

    def listJson() {
        //println("params--->"+params);

        params.max = Math.min(params.limit as Integer ?: 10, 100)
        params.offset= params.start

        def conditions={
            <%
            excludedProps = Event.allEvents.toList() << 'version' << 'dateCreated' << 'lastUpdated'
            persistentPropNames = domainClass.persistentProperties*.name
            boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate')
            if (hasHibernate && org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsDomainBinder.getMapping(domainClass)?.identity?.generator == 'assigned') {
                persistentPropNames << domainClass.identifier.name
            }
            props = domainClass.properties.findAll { persistentPropNames.contains(it.name) && !excludedProps.contains(it.name) }
            Collections.sort(props, comparator.constructors[0].newInstance([domainClass] as Object[]))
            props.eachWithIndex { p, i ->
                %>
                if(params.${p.name}&&params.${p.name}=="true"){
                    <%
                    if(p.type==String){ %>
                        if(params.${p.name}&&params.${p.name}=="true"){
                            if(params.${p.name}Operator=="contains"){
                                like("${p.name}","%"+params.${p.name}Key+"%");
                            }else if(params.${p.name}Operator=="start"){
                                like("${p.name}",params.${p.name}Key+"%");
                            } else if(params.${p.name}Operator=="end"){
                                like("${p.name}","%"+params.${p.name}Key);
                            }else if(params.${p.name}Operator=="equals"){
                                eq("${p.name}",params.${p.name}Key);
                            }
                        }
                        <%}else if(p.type==int||p.type==Integer){%>
                        int ${p.name}Key=0;
                        try{
                            ${p.name}Key=Integer.parseInt(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==double||p.type==Double){%>
                        double  ${p.name}Key=0d;
                        try{
                            ${p.name}Key=Double.parseDouble(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==float||p.type==Float){%>
                        float ${p.name}Key=0f;
                        try{
                            ${p.name}Key=Float.parseFloat(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==short||p.type==Short){%>
                        short  ${p.name}Key=0;
                        try{
                            ${p.name}Key=Short.parseShort(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==byte||p.type==Byte){%>
                        byte ${p.name}Key=0;
                        try{
                            ${p.name}Key=Byte.parseByte(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==long||p.type==Long){%>
                        long  ${p.name}Key=0l;
                        try{
                            ${p.name}Key=Long.parseLong(params.${p.name}Key);
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if(p.type==char||p.type==Character){%>
                        char  ${p.name}Key=0;
                        try{
                            ${p.name}Key=params.${p.name}Key.toCharacter()[0];
                        }catch (Exception ex){}
                        if(params.${p.name}Operator=="equals"){
                            eq("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="gt"){
                            gt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="ge"){
                            ge("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="lt"){
                            lt("${p.name}",${p.name}Key);
                        }else if(params.${p.name}Operator=="le"){
                            le("${p.name}",${p.name}Key);
                        }
                        <%}else if (p.manyToOne || p.oneToOne){
                        if(p.referencedDomainClass){%>
                            long  ${p.name}Key=0l;
                            try{
                                ${p.name}Key=Long.parseLong(params.${p.name}Key);
                            }catch (Exception ex){}
                            def ${p.referencedDomainClass?.propertyName}=${p.referencedDomainClass?.fullName}.get(${p.name}Key);
                            if(${p.referencedDomainClass?.propertyName}){
                                eq("${p.name}",${p.referencedDomainClass?.propertyName});
                            }
                            <%}}else if (p.type == Boolean || p.type == boolean) {%>
                        boolean  ${p.name}Key=true;
                        try{
                            ${p.name}Key=Boolean.getBoolean(params.${p.name}Key);
                        }catch (Exception ex){}
                        eq("${p.name}",${p.name}Key);
                        <%}else if(p.type == TimeZone){%>
                        eq("${p.name}",TimeZone.getTimeZone(params.${p.name}Key));
                        <%}else if(p.type == Locale){%>
                        if(params.${p.name}Key){
                            String language="";
                            String country="";
                            String ${p.name}Key=params.${p.name}Key;
                            int i=${p.name}Key.indexOf("_");
                            if(i==-1){
                                language=${p.name}Key;
                            }else {
                                language=${p.name}Key.substring(0,i);
                                country=${p.name}Key.substring(i+1);
                            }
                            eq("${p.name}",new Locale(language,country));
                        }
                        <%}else if(p.type == Currency){%>
                        eq("${p.name}",Currency.getInstance(params.${p.name}Key));
                        <%}%>
                }
                <%}%>
        }
        def rows=${className}.createCriteria().list(params,conditions);
        def totalCount = ${className}.createCriteria().count(conditions);
        //render(view:"/dbc/SecondTest/list",model:[secondTestInstanceList: SecondTest.list(params), secondTestInstanceTotal: SecondTest.count()])
        def resultObj=[rows : rows, //数据集合
                results : totalCount, //记录总数
                hasError : false, //是否存在错误
                error : "" // 仅在 hasError : true 时使用
        ];
        //println("resultObj-->"+(resultObj as JSON))
        render resultObj as JSON;
    }
    def deleteJson() {
        //println("params-->"+params)
        def idsP=params.get("ids[]");
        println("idsP-->"+idsP)
        def ids;
        if(idsP){
            if(idsP instanceof Object[]){
                ids=idsP;
            }else{
                ids=new String[1];
                ids[0]=idsP;
            }
            //println("ids-->"+idsP);
            for(int i=0;i<ids.length;i++){
                def id=ids[i];
                def ${propertyName} =  ${className}.get(id)
                try {
                    ${propertyName}.delete(flush: true)
                }
                catch (DataIntegrityViolationException e) {
                    def message = message(code: 'default.not.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), id])
                    def resultObj=[success:false,message:message];
                    render resultObj as JSON;
                    return
                }
            }
            def message = message(code: 'default.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ids])
            def resultObj=[success:true,message:message];
            render resultObj as JSON;
        }

    }
}
