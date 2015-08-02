<% import grails.persistence.Event %>
<%=packageName%>
<!DOCTYPE html>
<html>
	<head>
        <g:set var="entityName" value="\${message(code: '${domainClass.propertyName}.label', default: '${className}')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
        <link href="\${resource(dir: "/bui/css", file: "dpl-min.css")}" rel="stylesheet" type="text/css"/>
        <link href="\${resource(dir: "/bui/css", file: "bui-min.css")}" rel="stylesheet" type="text/css"/>
        <link href="\${resource(dir: "/bui/css", file: "main-min.css")}" rel="stylesheet" type="text/css"/>
        %{-- <g:javascript library="jquery"/>--}%
        <script type="text/javascript" src="\${resource(dir: "/bui", file: "jquery-1.8.1.min.js")}"></script>
        <script type="text/javascript" src="\${resource(dir: "/bui", file: "bui-min.js")}"></script>

	</head>
	<body style="margin: 15px;overflow: auto">
    <div class="panel" id="searchPanel">
        <div class="panel-header" style="height: 20px;">
            <div class="pull-left">
                <h3><g:message code="default.search.label" default="Search" /></h3>
            </div>
            <div class="pull-right">
                <button class="button button-small" onclick="expandSearchPanel()" id="searchPanelExpandBt" style="display: none;">
                    <i class="icon-chevron-down"></i>
                </button>
                <button class="button button-small" onclick="packUpSearchPanel()"  id="searchPanelPackUpBt">
                    <i class="icon-chevron-up"></i>
                </button>
            </div>
        </div>

        <%
        //excludedProps = Event.allEvents.toList() << 'id' << 'version'
        //allowedNames = domainClass.persistentProperties*.name << 'dateCreated' << 'lastUpdated'
        //props = domainClass.properties.findAll { allowedNames.contains(it.name) && !excludedProps.contains(it.name) && it.type != null && !Collection.isAssignableFrom(it.type) }
        excludedProps = Event.allEvents.toList() << 'version' << 'dateCreated' << 'lastUpdated'
        persistentPropNames = domainClass.persistentProperties*.name
        boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate')
        if (hasHibernate && org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsDomainBinder.getMapping(domainClass)?.identity?.generator == 'assigned') {
            persistentPropNames << domainClass.identifier.name
        }
        props = domainClass.properties.findAll { persistentPropNames.contains(it.name) && !excludedProps.contains(it.name) }
        Collections.sort(props, comparator.constructors[0].newInstance([domainClass] as Object[]))
        %>

        <div class="panel-body" id="searchPanmel-body">

            <form class="form-horizontal " id="searchForm">
                <table class="table" style="width: auto;">
                    <thead>
                    <tr>
                        <th><g:message code="default.search.field.label" default="Search Field" /></th>
                        <th>
                            <select id="addSFRowSelect">
                                <%
                                props.eachWithIndex { p, i ->
                                    if((p.oneToMany && !p.bidirectional) || (p.manyToMany && p.isOwningSide())){}else{
                                 %>
                                    <option value="${p.name}SFRow">
                                        <g:message code="${domainClass.propertyName}.${p.name}.label" default="${p.naturalName}" />
                                    </option>
                                <%  }} %>
                            </select>
                        </th>
                        <th>
                            <button type="button" class="button button-small" style="" id="addSFRowButton">
                                <g:message code="default.search.add.label" default="Add Field" />
                            </button>
                        </th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>

                    <%
                        props.eachWithIndex { p, i ->
                        if (hasHibernate) {
                            cp = domainClass.constrainedProperties[p.name]
                        }
                        if((p.oneToMany && !p.bidirectional) || (p.manyToMany && p.isOwningSide())){}else{
                    %>

                    <%if(i<6){%>
                    <tr id="${p.name}SFRow">
                        <input type="hidden" name="${p.name}" value="true"/>
                    <%}else{%>
                    <tr id="${p.name}SFRow" style="display: none;">
                        <input type="hidden" name="${p.name}" value="false"/>
                    <%}%>
                        <td style="border: 0">
                            <label for="${p.name}">
                                <g:message code="${domainClass.propertyName}.${p.name}.label" default="${p.naturalName}" />
                            </label>
                        </td>
                        <td style="border: 0">
                            <select name="${p.name}Operator">
                                <option value="equals">
                                    <g:message code="default.search.operator.equals.label" default="Equals" />
                                </option>
                                <%if (p.type == String){%>
                                    <option value="contains">
                                        <g:message code="default.search.operator.contains.label" default="Contains" />
                                    </option>
                                    <option value="start">
                                        <g:message code="default.search.operator.start.label" default="Start" />
                                    </option>
                                    <option value="end">
                                        <g:message code="default.search.operator.end.label" default="End" />
                                    </option>
                                <%}else if(p.type && Number.isAssignableFrom(p.type) || (p.type?.isPrimitive() && p.type != boolean)||(p.type == Date || p.type == java.sql.Date || p.type == java.sql.Time || p.type == Calendar)){%>
                                <option value="gt">
                                    <g:message code="default.search.operator.gt.label" default="Greater" />
                                </option>
                                <option value="ge">
                                    <g:message code="default.search.operator.ge.label" default="Greater or Equal" />
                                </option>
                                <option value="lt">
                                    <g:message code="default.search.operator.lt.label" default="Less" />
                                </option>
                                <option value="le">
                                    <g:message code="default.search.operator.le.label" default="Less or Equal" />
                                </option>
                                <%}else if((p.oneToMany && !p.bidirectional) || (p.manyToMany && p.isOwningSide())){%>
                                    <option value="contains">
                                        <g:message code="default.search.operator.contains.label" default="Contains" />
                                    </option>
                                <%}%>
                            </select>
                        </td>
                        <td style="border: 0">
                            <%if(p.type == TimeZone||p.type == Locale||p.type == Currency){
                                def type=""
                                if(p.type == TimeZone)
                                    type="timeZone"
                                else if(p.type == Locale)
                                    type="locale"
                                else if(p.type == Currency)
                                    type="currency"
                                if(!cp){%>
                                    <g:${type}Select name="${p.name}Key"/>
                                <%}else{%>
                                    <g:${type}Select name="${p.name}Key"
                                    <%if(cp.widget){%>
                                        widget="${cp.widget}"
                                    <%}
                                      cp.attributes.each { k, v ->%>
                                    ${k}="${v}"
                                    <%}%> />
                            <%}}else if (p.type && p.isEnum()) { %>
                                <g:select name="${p.name}Key" from="\${${property.type.name}?.values()}" keys="\${${p.type.name}.values()*.name()}"/>
                            <%}else if (p.manyToOne || p.oneToOne){%>
                                <g:select name="${p.name}Key" from="\${${p.type.name}.list()}" optionKey="id" class="many-to-one"/>
                            <%}else if((p.oneToMany && !p.bidirectional) || (p.manyToMany && p.isOwningSide())){
                                def cls = p.referencedDomainClass?.clazz
                                if (cls == null) {
                                    if (p.type instanceof Collection) {
                                        cls = org.springframework.core.GenericCollectionTypeResolver.getCollectionType(p.type)
                                    }
                                }
                                if (cls != null) {
                            %>
                                <g:select name="${p.name}Key" from="\${${cls.name}.list()}" size="5" multiple="multiple" optionKey="id" class="control-row3"/>
                            <% }
                            }else if (p.type == Date || p.type == java.sql.Date || p.type == java.sql.Time || p.type == Calendar){%>
                                <input name="${p.name}Key" type="text" class="calendar calendar-time" />
                            <%  } else if (p.type == Boolean || p.type == boolean) { %>
                                <select  name="${p.name}Key">
                                    <option value="true"><g:formatBoolean boolean="true" /></option>
                                    <option value="false"><g:formatBoolean boolean="false" /></option>
                                </select>
                            <%  } else if(p.type && Number.isAssignableFrom(p.type) || (p.type?.isPrimitive() && p.type != boolean)){%>
                                <%if(!cp&&p.type == Byte){%>
                                <g:select name="${p.name}Key" from="\${-128..127}"/>
                                <%}else if(cp.range){%>
                                <g:select name="${p.name}Key" from="\${${cp.range.from}..${cp.range.to}}"/>
                                <%}else if(cp.inList){%>
                                <g:select name="${p.name}Key" from="\${${className}.constraints.${p.name}.inList}"/>
                                <%}else{%>
                                <g:field name="${p.name}Key" type="number" value=""/>
                                <%}%>
                            <%}else{%>
                                <g:textField name="${p.name}Key" value=""/>
                            <%}%>
                        </td>
                        <td style="border: 0">
                            <button type="button" class="button button-small" style="" data-name="removeSFRow">
                                <i class="icon-remove"></i>
                            </button>
                        </td>
                    </tr>
                    <%  }} %>

                    <tr>
                        <td style="border: 0"></td>
                        <td style="border: 0"></td>
                        <td style="border: 0"></td>
                        <td style="border: 0">
                            <button  type="button" id="btnSearch" class="button button-primary">
                                \${message(code: 'default.button.search.label', default: 'Search')}
                            </button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </form>
        </div>
    </div>


    <div class="search-grid-container">
        <div id="grid" style="margin-right: 5px;"></div>
    </div>




	</body>



<script type="text/javascript">
    function packUpSearchPanel(){
        \$("#searchPanmel-body").hide(300);
        \$("#searchPanelExpandBt").show();
        \$("#searchPanelPackUpBt").hide();
    }
    function expandSearchPanel(){
        \$("#searchPanmel-body").show(300);
        \$("#searchPanelExpandBt").hide();
        \$("#searchPanelPackUpBt").show();
    }
</script>

<script type="text/javascript">
    BUI.use('bui/calendar',function(Calendar){
        var datepicker = new Calendar.DatePicker({
            trigger:'.calendar-time',
            showTime : true,
            dateMask : 'yyyy-mm-dd HH:MM:ss',
            autoRender : true
        });
    });
</script>

<script type="text/javascript">
    BUI.use(['common/search', 'common/page'], function (Search) {

        var columns = [
                    {title: '<g:message code="${domainClass.propertyName}.id.label" default="Id"/>', dataIndex: 'id', width: 80, renderer: function (item) {
                        return Search.createLink({
                            id: item,
                            title: '\${message(code: '${domainClass.propertyName}.label', default: '${className}')}:'+item,
                            text: item,
                            href: '\${createLink(action: "show")}/'+item
                        });
                    }}
                    <%
                        props.eachWithIndex { p, i ->
							if (i < 10) {
							if(p.manyToOne || p.oneToOne){%>
                            ,{title: '\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}', dataIndex: '${p.name}', width: 100,renderer:function(item){
                        return Search.createLink({
                            id: item.id,
                            title:'\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}:'+item.id,
                            text:'\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}:'+ item.id,
                            href: '\${createLink(controller: "${p.referencedDomainClass?.propertyName}",action: "show")}/'+item.id
                        });}}
							<%}else if(p.oneToMany || p.manyToMany){%>
                    ,{title: '\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}', dataIndex: '${p.name}', width: 100,renderer:function(items){
                        var result="";
                        for(i=0;i<items.length;i++){
                            var item=items[i];
                            result+=Search.createLink({
                                id: item.id,
                                title:'\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}:'+item.id,
                                text:'\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}:'+ item.id,
                                href: '\${createLink(controller: "${p.referencedDomainClass?.propertyName}",action: "show")}/'+item.id
                            })+"<br/>";
                        }
                        return result;
                    }}
            <%}else if(p.type == TimeZone){%>
            ,{title: '\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}', dataIndex: '${p.name}', width: 100,renderer:function(item){
                return item.displayName;
            }}
                    <%}else{
					%>
                             ,{title: '\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}', dataIndex: '${p.name}', width: 100}
                    <%}
                    } }%>
                   ,
                    {title: '\${message(code: 'default.button.operate.label', default: 'Operate')}', dataIndex: '', width: 200, renderer: function (value, obj) {
                        return "<a class='grid-command btn-edit' href='\${createLink(action: "edit")}/"+obj.id+"'>\${message(code:"default.button.edit.label",default:"Edit")}</a>"+
                                '<span class="grid-command btn-del">\${message(code:"default.button.delete.label",default:"Delete")}</span>'
                    }}
                ],
                store = Search.createStore('\${createLink(action: "listJson")}', {
//                    limit:10,
                    autoSync: true //保存数据后，自动更新
                }),
                gridCfg = Search.createGridCfg(columns, {
                    tbar: {
                        items: [
                            {text: '<i class="icon-plus"></i>\${message(code:"default.button.new.label",default:"New")}', btnCls: 'button button-small', handler: addFunction},
                            {text: '<i class="icon-remove"></i>\${message(code:"default.button.delete.label",default:"Delete")}', btnCls: 'button button-small', handler: delFunction}
                        ]
                    },
                    plugins: [ BUI.Grid.Plugins.CheckSelection, BUI.Grid.Plugins.AutoFit] // 插件形式引入多选表格
                });

        var search = new Search({
                    store: store,
//                    limit:10,
                    gridCfg: gridCfg
                }),
                grid = search.get('grid');

        function addFunction() {
            location.href='\${createLink(action: "create")}';
        }

        //删除操作
        function delFunction(){
            var selections = grid.getSelection();
            delItems(selections);
        }

        function delItems(items){
            var ids = [];
            BUI.each(items,function(item){
                ids.push(item.id);
            });

            if(ids.length){
                BUI.Message.Confirm('\${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}',function(){
                    \$.ajax({
                        url : '\${createLink(action: "deleteJson")}',
                        type:"post",
                        dataType : 'json',
                        data : {ids : ids},
                        success : function(data){
                            if(data.success){ //删除成功
                                search.load();
                            }else{ //删除失败
                                BUI.Message.Alert('删除失败！');
                            }
                        }
                    });
                },'question');
            }
        }

        //监听事件，删除一条记录
        grid.on('cellclick', function (ev) {
            var sender = \$(ev.domTarget); //点击的Dom
            if (sender.hasClass('btn-del')) {
                var record = ev.record;
                delItems([record]);
            }
        });

        \$("button[data-name='removeSFRow']").click(function(){
            \$(this).parent().parent().css("display","none");
            \$(this).parent().parent().children("input[type='hidden']").val("false");
        });
        \$("#addSFRowButton").click(function(){
            var addSFRowSelectStr=\$("#addSFRowSelect").val();
            \$("#"+addSFRowSelectStr).css("display","");
            \$("#"+addSFRowSelectStr).children("input[type='hidden']").val("true");
        });
    });
</script>
</html>
