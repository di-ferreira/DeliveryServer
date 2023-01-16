describe('Rotas Tipo Cardápio', () => {
    let id01:number;
    let id02:number;

    it('Create Tipo Cardápio 01', () => {
        cy.request({
            method: 'POST',
            url: '/cardapios/tipos',
            body: {
                "id": 0,
                "descricao": 'massas'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Tipo de Cardápio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('massas');
            id01 = Response.body[1].id;
        });
    });

    it('Create Tipo Cardápio 02', () => {
        cy.request({
            method: 'POST',
            url: '/cardapios/tipos',
            body: {
                "id": 0,
                "descricao": 'sanduíches'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Tipo de Cardápio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('sanduíches');
            id02 = Response.body[1].id;
        });
    });

    it('Get all Tipo Cardápio', () => {
        cy.request('/cardapios/tipos').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].id).to.equal(id01);
            expect(Response.body[0].descricao).to.equal('massas');
            expect(Response.body[1].id).to.equal(id02);
            expect(Response.body[1].descricao).to.equal('sanduíches');
        });
    });

    it('Get Tipo Cardápio 01', () => {
        cy.request(`/cardapios/tipos/${id01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id01);
            expect(Response.body.descricao).to.equal('massas');
        });
    });

    it('Get Tipo Cardápio 02', () => {
        cy.request(`/cardapios/tipos/${id02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id02);
            expect(Response.body.descricao).to.equal('sanduíches');
        });
    });

    it('Update Tipo Cardápio 01', () => {
        cy.request({
            method: 'PUT',
            url: `/cardapios/tipos/${id01}`,
            body: {
                "id": id01,
                "descricao": 'pizzas'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Tipo de Cardápio atualizado com sucesso!');
            expect(Response.body[1].descricao).to.equal('pizzas');
            expect(Response.body[1].id).to.equal(id01);
        });
    });

    it('Update Tipo Cardápio 02', () => {
        cy.request({
            method: 'PUT',
            url: `/cardapios/tipos/${id02}`,
            body: {
                "id": id02,
                "descricao": 'hamburgues'
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Tipo de Cardápio atualizado com sucesso!');
            expect(Response.body[1].descricao).to.equal('hamburgues');
            expect(Response.body[1].id).to.equal(id02);
        });
    });

    it('Delete Tipo Cardápio 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/cardapios/tipos/${id01}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Tipo de Cardápio excluído com sucesso!');
        });
    });

    it('Delete Tipo Cardápio 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/cardapios/tipos/${id02}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('Tipo de Cardápio excluído com sucesso!');
        });
    });
});